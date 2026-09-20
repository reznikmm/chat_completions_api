--
--  Copyright (c) 2026, OpenAI
--
--  SPDX-License-Identifier: MIT
--

pragma Ada_2022;
with Minimal_Perfect_Hash;
with VSS.JSON.Pull_Readers.Buffered;

package body Chat_Completions_API.Types.Inputs is
   pragma Style_Checks (Off);
   use type VSS.JSON.JSON_Number_Kind;
   use type VSS.Strings.Virtual_String;

   procedure Input_Any_Value
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Any_Value'Class;
      Success : in out Boolean)
   is
      use type VSS.JSON.Streams.JSON_Stream_Element_Kind;
   begin
      case Reader.Element_Kind is
         when VSS.JSON.Streams.Start_Array  =>
            Value.Append ((Kind => VSS.JSON.Streams.Start_Array));
            Reader.Read_Next;
            while Success and Reader.Element_Kind /= VSS.JSON.Streams.End_Array
            loop
               Input_Any_Value (Reader, Value, Success);
            end loop;
            Value.Append ((Kind => VSS.JSON.Streams.End_Array));

         when VSS.JSON.Streams.Start_Object =>
            Value.Append ((Kind => VSS.JSON.Streams.Start_Object));
            Reader.Read_Next;
            while Success and Reader.Element_Kind = VSS.JSON.Streams.Key_Name
            loop
               Value.Append (Reader.Element);
               Reader.Read_Next;
               Input_Any_Value (Reader, Value, Success);
            end loop;
            Value.Append ((Kind => VSS.JSON.Streams.End_Object));

         when VSS.JSON.Streams.String_Value
            | VSS.JSON.Streams.Number_Value
            | VSS.JSON.Streams.Boolean_Value
            | VSS.JSON.Streams.Null_Value   =>
            Value.Append (Reader.Element);

         when others                        =>
            Success := False;
      end case;
      if Success then
         Reader.Read_Next;
      end if;
   end Input_Any_Value;

   package ChatCompletionChoice_finish_reason_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["stop", "length", "tool_calls", "content_filter", "function_call"]);

   procedure Input_ChatCompletionChoice_finish_reason
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionChoice_finish_reason;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           ChatCompletionChoice_finish_reason_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := ChatCompletionChoice_finish_reason'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_ChatCompletionChoice_finish_reason;

   package ChatCompletionToolChoiceOption_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["none", "auto", "required"]);

   procedure Input_ChatCompletionToolChoiceOption
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionToolChoiceOption;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           ChatCompletionToolChoiceOption_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := ChatCompletionToolChoiceOption'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_ChatCompletionToolChoiceOption;

   package ChatCompletionRequestMessage_role_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["system", "user", "assistant", "tool"]);

   procedure Input_ChatCompletionRequestMessage_role
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionRequestMessage_role;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           ChatCompletionRequestMessage_role_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := ChatCompletionRequestMessage_role'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_ChatCompletionRequestMessage_role;

   package ChatCompletionResponseFormatOption_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["text", "json_schema", "json_object"]);

   package ResponseFormatText_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["type"]);

   procedure Input_ResponseFormatText
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatText;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ResponseFormatText_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "text"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ResponseFormatText;

   package ChatCompletionMessageToolCall_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["id", "type", "function"]);

   package ChatCompletionMessageToolCall_function_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["name", "arguments"]);

   procedure Input_ChatCompletionMessageToolCall
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionMessageToolCall;
      Success : in out Boolean)
   is
      procedure Input_ChatCompletionMessageToolCall_function
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ChatCompletionMessageToolCall_function;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ChatCompletionMessageToolCall_function_Minimal_Perfect_Hash
                      .Get_Index (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  name
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_String_Value then
                              Value.name := Reader.String_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 2      =>
                        --  arguments
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_String_Value then
                              Value.arguments := Reader.String_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ChatCompletionMessageToolCall_function;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionMessageToolCall_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  id
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.id := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "function"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  function
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionMessageToolCall_function
                          (Reader, Value.a_function, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionMessageToolCall;

   package ChatCompletionTokenLogprob_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["token", "logprob", "bytes"]);

   procedure Input_ChatCompletionTokenLogprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionTokenLogprob;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionTokenLogprob_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  token
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.token := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  logprob
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.logprob :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.logprob := Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  bytes
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.bytes.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : Integer_64;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    if Reader.Is_Number_Value
                                      and then Reader.Number_Value.Kind
                                               = VSS.JSON.JSON_Integer
                                    then
                                       Item :=
                                         Reader.Number_Value.Integer_Value;
                                       Reader.Read_Next;
                                    else
                                       Success := False;
                                    end if;
                                 end if;
                                 Value.bytes.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionTokenLogprob;

   package ChatCompletionChoice_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["finish_reason", "index", "message", "logprobs"]);

   package ChatCompletionChoice_logprobs_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["content", "refusal"]);

   procedure Input_ChatCompletionChoice
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionChoice;
      Success : in out Boolean)
   is
      procedure Input_ChatCompletionChoice_logprobs
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ChatCompletionChoice_logprobs;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ChatCompletionChoice_logprobs_Minimal_Perfect_Hash
                      .Get_Index (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  content
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Success and Reader.Is_Start_Array then
                              Reader.Read_Next;
                              Value.content.Clear (Is_Null => False);
                              while Success and not Reader.Is_End_Array loop
                                 declare
                                    Item : ChatCompletionTokenLogprob;
                                 begin
                                    if Reader.Is_Null_Value then
                                       Reader.Read_Next;
                                    else
                                       Input_ChatCompletionTokenLogprob
                                         (Reader, Item, Success);
                                    end if;
                                    Value.content.Append (Item);
                                 end;
                              end loop;
                              if Success then
                                 Reader.Read_Next;  --  skip End_Array

                              end if;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 2      =>
                        --  refusal
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Success and Reader.Is_Start_Array then
                              Reader.Read_Next;
                              Value.refusal.Clear (Is_Null => False);
                              while Success and not Reader.Is_End_Array loop
                                 declare
                                    Item : ChatCompletionTokenLogprob;
                                 begin
                                    if Reader.Is_Null_Value then
                                       Reader.Read_Next;
                                    else
                                       Input_ChatCompletionTokenLogprob
                                         (Reader, Item, Success);
                                    end if;
                                    Value.refusal.Append (Item);
                                 end;
                              end loop;
                              if Success then
                                 Reader.Read_Next;  --  skip End_Array

                              end if;
                           else
                              Success := False;
                           end if;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ChatCompletionChoice_logprobs;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionChoice_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  finish_reason
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionChoice_finish_reason
                          (Reader, Value.finish_reason, Success);
                     end if;

                  when 2      =>
                     --  index
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.index := Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  message
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionResponseMessage
                          (Reader, Value.message, Success);
                     end if;

                  when 4      =>
                     --  logprobs
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionChoice_logprobs
                          (Reader, Value.logprobs, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionChoice;

   procedure Input_ChatCompletionResponseFormatOption
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionResponseFormatOption;
      Success : in out Boolean)
   is
      use all type VSS.JSON.Streams.JSON_Stream_Element_Kind;

      Look_Ahead :
        VSS.JSON.Pull_Readers.Buffered.JSON_Buffered_Pull_Reader
          (Reader'Access);

      Variant_Key : constant VSS.Strings.Virtual_String := "kind";
   begin
      Look_Ahead.Mark;
      if Success and Look_Ahead.Is_Start_Object then
         Look_Ahead.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Look_Ahead.Is_End_Object loop
         if not Look_Ahead.Is_Key_Name then
            Success := False;
         elsif Look_Ahead.Key_Name /= Variant_Key then
            Look_Ahead.Skip_Current_Value;
            Success := not Look_Ahead.Is_End_Object;
         elsif Look_Ahead.Read_Next = String_Value then
            declare
               Index : constant Natural :=
                 ChatCompletionResponseFormatOption_Minimal_Perfect_Hash
                   .Get_Index (Look_Ahead.String_Value);
            begin
               Look_Ahead.Reset;
               Look_Ahead.Unmark;

               case Index is
                  when 1      =>
                     --  text
                     Value.Union := (Kind => text, others => <>);
                     Input_ResponseFormatText
                       (Look_Ahead, Value.Union.text, Success);

                  when 2      =>
                     --  json_schema
                     Value.Union := (Kind => json_schema, others => <>);
                     Input_ResponseFormatJsonSchema
                       (Look_Ahead, Value.Union.json_schema, Success);

                  when 3      =>
                     --  json_object
                     Value.Union := (Kind => json_object, others => <>);
                     Input_ResponseFormatJsonObject
                       (Look_Ahead, Value.Union.json_object, Success);

                  when others =>
                     Success := False;
               end case;

               return;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Look_Ahead.Read_Next;  --  skip End_Object
         Success := False;
      end if;
   end Input_ChatCompletionResponseFormatOption;

   package CreateChatCompletionRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["temperature",
         "top_p",
         "user",
         "messages",
         "model",
         "max_completion_tokens",
         "frequency_penalty",
         "presence_penalty",
         "top_logprobs",
         "response_format",
         "stream",
         "stop",
         "logprobs",
         "n",
         "seed",
         "tools",
         "tool_choice",
         "parallel_tool_calls"]);

   procedure Input_CreateChatCompletionRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateChatCompletionRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 CreateChatCompletionRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  temperature
                     Reader.Read_Next;
                     Value.temperature := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.temperature.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.temperature.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  top_p
                     Reader.Read_Next;
                     Value.top_p := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.top_p.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.top_p.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  user
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.user := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 4      =>
                     --  messages
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.messages.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ChatCompletionRequestMessage;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    Input_ChatCompletionRequestMessage
                                      (Reader, Item, Success);
                                 end if;
                                 Value.messages.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 5      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.model := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 6      =>
                     --  max_completion_tokens
                     Reader.Read_Next;
                     Value.max_completion_tokens :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.max_completion_tokens.Value :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 7      =>
                     --  frequency_penalty
                     Reader.Read_Next;
                     Value.frequency_penalty := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.frequency_penalty.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.frequency_penalty.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 8      =>
                     --  presence_penalty
                     Reader.Read_Next;
                     Value.presence_penalty := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.presence_penalty.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.presence_penalty.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 9      =>
                     --  top_logprobs
                     Reader.Read_Next;
                     Value.top_logprobs := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.top_logprobs.Value :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 10     =>
                     --  response_format
                     Reader.Read_Next;
                     Value.response_format := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionResponseFormatOption
                          (Reader, Value.response_format.Value, Success);
                     end if;

                  when 11     =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Boolean_Value then
                           Value.stream := Reader.Boolean_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 12     =>
                     --  stop
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.stop.Clear;
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : VSS.Strings.Virtual_String;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    if Reader.Is_String_Value then
                                       Item := Reader.String_Value;
                                       Reader.Read_Next;
                                    else
                                       Success := False;
                                    end if;
                                 end if;
                                 Value.stop.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 13     =>
                     --  logprobs
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Boolean_Value then
                           Value.logprobs := Reader.Boolean_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 14     =>
                     --  n
                     Reader.Read_Next;
                     Value.n := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.n.Value := Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 15     =>
                     --  seed
                     Reader.Read_Next;
                     Value.seed := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.seed.Value :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 16     =>
                     --  tools
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.tools.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ChatCompletionTool;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    Input_ChatCompletionTool
                                      (Reader, Item, Success);
                                 end if;
                                 Value.tools.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 17     =>
                     --  tool_choice
                     Reader.Read_Next;
                     Value.tool_choice := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionToolChoiceOption
                          (Reader, Value.tool_choice.Value, Success);
                     end if;

                  when 18     =>
                     --  parallel_tool_calls
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Boolean_Value then
                           Value.parallel_tool_calls := Reader.Boolean_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_CreateChatCompletionRequest;

   procedure Input_FunctionParameters
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out FunctionParameters;
      Success : in out Boolean) is
   begin
      Input_Any_Value (Reader, Value, Success);
   end Input_FunctionParameters;

   package ResponseFormatJsonObject_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["type"]);

   procedure Input_ResponseFormatJsonObject
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonObject;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ResponseFormatJsonObject_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "json_object"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ResponseFormatJsonObject;

   package ChatCompletionResponseMessage_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["content", "refusal", "tool_calls", "role"]);

   procedure Input_ChatCompletionResponseMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionResponseMessage;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionResponseMessage_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  content
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.content := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  refusal
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.refusal := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  tool_calls
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.tool_calls.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ChatCompletionMessageToolCall;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    Input_ChatCompletionMessageToolCall
                                      (Reader, Item, Success);
                                 end if;
                                 Value.tool_calls.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 4      =>
                     --  role
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "assistant"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionResponseMessage;

   package ModelResponseProperties_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["temperature", "top_p", "user"]);

   procedure Input_ModelResponseProperties
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelResponseProperties;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ModelResponseProperties_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  temperature
                     Reader.Read_Next;
                     Value.temperature := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.temperature.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.temperature.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  top_p
                     Reader.Read_Next;
                     Value.top_p := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value then
                           if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                           then
                              Value.top_p.Value :=
                                Float_64 (Reader.Number_Value.Integer_Value);
                           elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                           then
                              Value.top_p.Value :=
                                Reader.Number_Value.Float_Value;
                           else
                              Success := False;
                           end if;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  user
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.user := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ModelResponseProperties;

   package ChatCompletionTool_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["type", "function"]);

   procedure Input_ChatCompletionTool
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionTool;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionTool_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "function"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  function
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_FunctionObject
                          (Reader, Value.a_function, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionTool;

   package ChatCompletionRequestMessage_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["role", "content", "name", "tool_call_id", "tool_calls"]);

   procedure Input_ChatCompletionRequestMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionRequestMessage;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatCompletionRequestMessage_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  role
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ChatCompletionRequestMessage_role
                          (Reader, Value.role, Success);
                     end if;

                  when 2      =>
                     --  content
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.content := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  name
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.name := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 4      =>
                     --  tool_call_id
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.tool_call_id := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 5      =>
                     --  tool_calls
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.tool_calls.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ChatCompletionMessageToolCall;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    Input_ChatCompletionMessageToolCall
                                      (Reader, Item, Success);
                                 end if;
                                 Value.tool_calls.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatCompletionRequestMessage;

   package CreateChatCompletionResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["id",
         "choices",
         "created",
         "model",
         "system_fingerprint",
         "object",
         "usage"]);

   procedure Input_CreateChatCompletionResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateChatCompletionResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 CreateChatCompletionResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  id
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.id := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  choices
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.choices.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ChatCompletionChoice;
                              begin
                                 if Reader.Is_Null_Value then
                                    Reader.Read_Next;
                                 else
                                    Input_ChatCompletionChoice
                                      (Reader, Item, Success);
                                 end if;
                                 Value.choices.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  created
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.created := Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 4      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.model := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 5      =>
                     --  system_fingerprint
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.system_fingerprint := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 6      =>
                     --  object
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "chat.completion"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  usage
                     Reader.Read_Next;
                     Value.usage := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_CompletionUsage
                          (Reader, Value.usage.Value, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_CreateChatCompletionResponse;

   package CompletionUsage_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["completion_tokens",
         "prompt_tokens",
         "total_tokens",
         "completion_tokens_details",
         "prompt_tokens_details"]);

   package CompletionUsage_completion_tokens_details_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["accepted_prediction_tokens",
         "audio_tokens",
         "reasoning_tokens",
         "rejected_prediction_tokens"]);

   package CompletionUsage_prompt_tokens_details_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["audio_tokens", "cached_tokens"]);

   procedure Input_CompletionUsage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CompletionUsage;
      Success : in out Boolean)
   is
      procedure Input_CompletionUsage_completion_tokens_details
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out CompletionUsage_completion_tokens_details;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    CompletionUsage_completion_tokens_details_Minimal_Perfect_Hash
                      .Get_Index (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  accepted_prediction_tokens
                        Reader.Read_Next;
                        Value.accepted_prediction_tokens :=
                          (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.accepted_prediction_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 2      =>
                        --  audio_tokens
                        Reader.Read_Next;
                        Value.audio_tokens := (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.audio_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 3      =>
                        --  reasoning_tokens
                        Reader.Read_Next;
                        Value.reasoning_tokens :=
                          (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.reasoning_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 4      =>
                        --  rejected_prediction_tokens
                        Reader.Read_Next;
                        Value.rejected_prediction_tokens :=
                          (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.rejected_prediction_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_CompletionUsage_completion_tokens_details;

      procedure Input_CompletionUsage_prompt_tokens_details
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out CompletionUsage_prompt_tokens_details;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    CompletionUsage_prompt_tokens_details_Minimal_Perfect_Hash
                      .Get_Index (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  audio_tokens
                        Reader.Read_Next;
                        Value.audio_tokens := (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.audio_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 2      =>
                        --  cached_tokens
                        Reader.Read_Next;
                        Value.cached_tokens := (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Number_Value
                             and then Reader.Number_Value.Kind
                                      = VSS.JSON.JSON_Integer
                           then
                              Value.cached_tokens.Value :=
                                Reader.Number_Value.Integer_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_CompletionUsage_prompt_tokens_details;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 CompletionUsage_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  completion_tokens
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.completion_tokens :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  prompt_tokens
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.prompt_tokens :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  total_tokens
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Number_Value
                          and then Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                        then
                           Value.total_tokens :=
                             Reader.Number_Value.Integer_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 4      =>
                     --  completion_tokens_details
                     Reader.Read_Next;
                     Value.completion_tokens_details :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_CompletionUsage_completion_tokens_details
                          (Reader,
                           Value.completion_tokens_details.Value,
                           Success);
                     end if;

                  when 5      =>
                     --  prompt_tokens_details
                     Reader.Read_Next;
                     Value.prompt_tokens_details :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_CompletionUsage_prompt_tokens_details
                          (Reader, Value.prompt_tokens_details.Value, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_CompletionUsage;

   package FunctionObject_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["description", "name", "parameters", "strict"]);

   procedure Input_FunctionObject
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out FunctionObject;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 FunctionObject_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  description
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.description := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 2      =>
                     --  name
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_String_Value then
                           Value.name := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when 3      =>
                     --  parameters
                     Reader.Read_Next;
                     Value.parameters := (Is_Set => True, Value => <>);
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_FunctionParameters
                          (Reader, Value.parameters.Value, Success);
                     end if;

                  when 4      =>
                     --  strict
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        if Reader.Is_Boolean_Value then
                           Value.strict := Reader.Boolean_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_FunctionObject;

   procedure Input_ResponseFormatJsonSchemaSchema
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonSchemaSchema;
      Success : in out Boolean) is
   begin
      Input_Any_Value (Reader, Value, Success);
   end Input_ResponseFormatJsonSchemaSchema;

   package ResponseFormatJsonSchema_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["type", "json_schema"]);

   package ResponseFormatJsonSchema_json_schema_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["description", "name", "schema", "strict"]);

   procedure Input_ResponseFormatJsonSchema
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonSchema;
      Success : in out Boolean)
   is
      procedure Input_ResponseFormatJsonSchema_json_schema
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ResponseFormatJsonSchema_json_schema;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ResponseFormatJsonSchema_json_schema_Minimal_Perfect_Hash
                      .Get_Index (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  description
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_String_Value then
                              Value.description := Reader.String_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 2      =>
                        --  name
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_String_Value then
                              Value.name := Reader.String_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when 3      =>
                        --  schema
                        Reader.Read_Next;
                        Value.schema := (Is_Set => True, Value => <>);
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           Input_ResponseFormatJsonSchemaSchema
                             (Reader, Value.schema.Value, Success);
                        end if;

                     when 4      =>
                        --  strict
                        Reader.Read_Next;
                        if Reader.Is_Null_Value then
                           Reader.Read_Next;
                        else
                           if Reader.Is_Boolean_Value then
                              Value.strict := Reader.Boolean_Value;
                              Reader.Read_Next;
                           else
                              Success := False;
                           end if;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ResponseFormatJsonSchema_json_schema;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ResponseFormatJsonSchema_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "json_schema"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  json_schema
                     Reader.Read_Next;
                     if Reader.Is_Null_Value then
                        Reader.Read_Next;
                     else
                        Input_ResponseFormatJsonSchema_json_schema
                          (Reader, Value.json_schema, Success);
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ResponseFormatJsonSchema;

end Chat_Completions_API.Types.Inputs;
