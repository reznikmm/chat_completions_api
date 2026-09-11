--
--  Copyright (c) 2026, OpenAI
--
--  SPDX-License-Identifier: MIT
--

package body Chat_Completions_API.Types.Outputs is
   pragma Style_Checks (Off);
   procedure Output_Any_Value
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Any_Value'Class) is
   begin
      for Item of Value loop
         case Item.Kind is
            when VSS.JSON.Streams.Start_Array    =>
               Handler.Start_Array;

            when VSS.JSON.Streams.End_Array      =>
               Handler.End_Array;

            when VSS.JSON.Streams.Start_Object   =>
               Handler.Start_Object;

            when VSS.JSON.Streams.End_Object     =>
               Handler.End_Object;

            when VSS.JSON.Streams.Key_Name       =>
               Handler.Key_Name (Item.Key_Name);

            when VSS.JSON.Streams.String_Value   =>
               Handler.String_Value (Item.String_Value);

            when VSS.JSON.Streams.Number_Value   =>
               Handler.Number_Value (Item.Number_Value);

            when VSS.JSON.Streams.Boolean_Value  =>
               Handler.Boolean_Value (Item.Boolean_Value);

            when VSS.JSON.Streams.Null_Value     =>
               Handler.Null_Value;

            when VSS.JSON.Streams.None           =>
               null;

            when VSS.JSON.Streams.Invalid        =>
               raise Program_Error;

            when VSS.JSON.Streams.Start_Document =>
               raise Program_Error;

            when VSS.JSON.Streams.End_Document   =>
               raise Program_Error;

            when VSS.JSON.Streams.Comment        =>
               raise Program_Error;
         end case;
      end loop;
   end Output_Any_Value;

   procedure Output_ChatCompletionChoice_finish_reason
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionChoice_finish_reason) is
   begin
      case Value is
         when stop           =>
            Handler.String_Value ("stop");

         when length         =>
            Handler.String_Value ("length");

         when tool_calls     =>
            Handler.String_Value ("tool_calls");

         when content_filter =>
            Handler.String_Value ("content_filter");

         when function_call  =>
            Handler.String_Value ("function_call");
      end case;
   end Output_ChatCompletionChoice_finish_reason;

   procedure Output_ChatCompletionToolChoiceOption
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionToolChoiceOption) is
   begin
      case Value is
         when none     =>
            Handler.String_Value ("none");

         when auto     =>
            Handler.String_Value ("auto");

         when required =>
            Handler.String_Value ("required");
      end case;
   end Output_ChatCompletionToolChoiceOption;

   procedure Output_ChatCompletionRequestMessage_role
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionRequestMessage_role) is
   begin
      case Value is
         when system    =>
            Handler.String_Value ("system");

         when user      =>
            Handler.String_Value ("user");

         when assistant =>
            Handler.String_Value ("assistant");

         when tool      =>
            Handler.String_Value ("tool");
      end case;
   end Output_ChatCompletionRequestMessage_role;

   procedure Output_ResponseFormatText
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatText) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("type");
      Handler.String_Value ("text");
      Handler.End_Object;
   end Output_ResponseFormatText;

   procedure Output_ChatCompletionMessageToolCall
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionMessageToolCall)
   is
      procedure Output_ChatCompletionMessageToolCall_function
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ChatCompletionMessageToolCall_function) is
      begin
         Handler.Start_Object;
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
         Handler.Key_Name ("arguments");
         Handler.String_Value (Value.arguments);
         Handler.End_Object;
      end Output_ChatCompletionMessageToolCall_function;

   begin
      Handler.Start_Object;
      Handler.Key_Name ("id");
      Handler.String_Value (Value.id);
      Handler.Key_Name ("type");
      Handler.String_Value ("function");
      Handler.Key_Name ("function");
      Output_ChatCompletionMessageToolCall_function
        (Handler, Value.a_function);
      Handler.End_Object;
   end Output_ChatCompletionMessageToolCall;

   procedure Output_ChatCompletionTokenLogprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionTokenLogprob) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("token");
      Handler.String_Value (Value.token);
      Handler.Key_Name ("logprob");
      Handler.Float_Value (Value.logprob);
      Handler.Key_Name ("bytes");
      Handler.Start_Array;
      for J in 1 .. Value.bytes.Length loop
         Handler.Integer_Value (Value.bytes (J));
      end loop;
      Handler.End_Array;
      Handler.End_Object;
   end Output_ChatCompletionTokenLogprob;

   procedure Output_ChatCompletionChoice
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionChoice)
   is
      procedure Output_ChatCompletionChoice_logprobs
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ChatCompletionChoice_logprobs) is
      begin
         Handler.Start_Object;
         Handler.Key_Name ("content");
         Handler.Start_Array;
         for J in 1 .. Value.content.Length loop
            Output_ChatCompletionTokenLogprob (Handler, Value.content (J));
         end loop;
         Handler.End_Array;
         Handler.Key_Name ("refusal");
         Handler.Start_Array;
         for J in 1 .. Value.refusal.Length loop
            Output_ChatCompletionTokenLogprob (Handler, Value.refusal (J));
         end loop;
         Handler.End_Array;
         Handler.End_Object;
      end Output_ChatCompletionChoice_logprobs;

   begin
      Handler.Start_Object;
      Handler.Key_Name ("finish_reason");
      Output_ChatCompletionChoice_finish_reason (Handler, Value.finish_reason);
      Handler.Key_Name ("index");
      Handler.Integer_Value (Value.index);
      Handler.Key_Name ("message");
      Output_ChatCompletionResponseMessage (Handler, Value.message);
      Handler.Key_Name ("logprobs");
      Output_ChatCompletionChoice_logprobs (Handler, Value.logprobs);
      Handler.End_Object;
   end Output_ChatCompletionChoice;

   procedure Output_ChatCompletionResponseFormatOption
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionResponseFormatOption) is
   begin
      case Value.Union.Kind is
         when text        =>
            Output_ResponseFormatText (Handler, Value.Union.text);

         when json_schema =>
            Output_ResponseFormatJsonSchema (Handler, Value.Union.json_schema);

         when json_object =>
            Output_ResponseFormatJsonObject (Handler, Value.Union.json_object);
      end case;
   end Output_ChatCompletionResponseFormatOption;

   procedure Output_CreateChatCompletionRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateChatCompletionRequest) is
   begin
      Handler.Start_Object;
      if Value.temperature.Is_Set then
         Handler.Key_Name ("temperature");
         Handler.Float_Value (Value.temperature.Value);
      end if;
      if Value.top_p.Is_Set then
         Handler.Key_Name ("top_p");
         Handler.Float_Value (Value.top_p.Value);
      end if;
      if not Value.user.Is_Null then
         Handler.Key_Name ("user");
         Handler.String_Value (Value.user);
      end if;
      Handler.Key_Name ("messages");
      Handler.Start_Array;
      for J in 1 .. Value.messages.Length loop
         Output_ChatCompletionRequestMessage (Handler, Value.messages (J));
      end loop;
      Handler.End_Array;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if Value.max_completion_tokens.Is_Set then
         Handler.Key_Name ("max_completion_tokens");
         Handler.Integer_Value (Value.max_completion_tokens.Value);
      end if;
      if Value.frequency_penalty.Is_Set then
         Handler.Key_Name ("frequency_penalty");
         Handler.Float_Value (Value.frequency_penalty.Value);
      end if;
      if Value.presence_penalty.Is_Set then
         Handler.Key_Name ("presence_penalty");
         Handler.Float_Value (Value.presence_penalty.Value);
      end if;
      if Value.top_logprobs.Is_Set then
         Handler.Key_Name ("top_logprobs");
         Handler.Integer_Value (Value.top_logprobs.Value);
      end if;
      if Value.response_format.Is_Set then
         Handler.Key_Name ("response_format");
         Output_ChatCompletionResponseFormatOption
           (Handler, Value.response_format.Value);
      end if;
      if Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      if Value.logprobs then
         Handler.Key_Name ("logprobs");
         Handler.Boolean_Value (Value.logprobs);
      end if;
      if Value.n.Is_Set then
         Handler.Key_Name ("n");
         Handler.Integer_Value (Value.n.Value);
      end if;
      if Value.seed.Is_Set then
         Handler.Key_Name ("seed");
         Handler.Integer_Value (Value.seed.Value);
      end if;
      if not Value.tools.Is_Null then
         Handler.Key_Name ("tools");
         Handler.Start_Array;
         for J in 1 .. Value.tools.Length loop
            Output_ChatCompletionTool (Handler, Value.tools (J));
         end loop;
         Handler.End_Array;
      end if;
      if Value.tool_choice.Is_Set then
         Handler.Key_Name ("tool_choice");
         Output_ChatCompletionToolChoiceOption
           (Handler, Value.tool_choice.Value);
      end if;
      if Value.parallel_tool_calls then
         Handler.Key_Name ("parallel_tool_calls");
         Handler.Boolean_Value (Value.parallel_tool_calls);
      end if;
      Handler.End_Object;
   end Output_CreateChatCompletionRequest;

   procedure Output_FunctionParameters
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : FunctionParameters) is
   begin
      Output_Any_Value (Handler, Value);
   end Output_FunctionParameters;

   procedure Output_ResponseFormatJsonObject
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonObject) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("type");
      Handler.String_Value ("json_object");
      Handler.End_Object;
   end Output_ResponseFormatJsonObject;

   procedure Output_ChatCompletionResponseMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionResponseMessage) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("content");
      Handler.String_Value (Value.content);
      Handler.Key_Name ("refusal");
      Handler.String_Value (Value.refusal);
      if not Value.tool_calls.Is_Null then
         Handler.Key_Name ("tool_calls");
         Handler.Start_Array;
         for J in 1 .. Value.tool_calls.Length loop
            Output_ChatCompletionMessageToolCall
              (Handler, Value.tool_calls (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.Key_Name ("role");
      Handler.String_Value ("assistant");
      Handler.End_Object;
   end Output_ChatCompletionResponseMessage;

   procedure Output_ModelResponseProperties
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelResponseProperties) is
   begin
      Handler.Start_Object;
      if Value.temperature.Is_Set then
         Handler.Key_Name ("temperature");
         Handler.Float_Value (Value.temperature.Value);
      end if;
      if Value.top_p.Is_Set then
         Handler.Key_Name ("top_p");
         Handler.Float_Value (Value.top_p.Value);
      end if;
      if not Value.user.Is_Null then
         Handler.Key_Name ("user");
         Handler.String_Value (Value.user);
      end if;
      Handler.End_Object;
   end Output_ModelResponseProperties;

   procedure Output_ChatCompletionTool
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionTool) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("type");
      Handler.String_Value ("function");
      Handler.Key_Name ("function");
      Output_FunctionObject (Handler, Value.a_function);
      Handler.End_Object;
   end Output_ChatCompletionTool;

   procedure Output_ChatCompletionRequestMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionRequestMessage) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("role");
      Output_ChatCompletionRequestMessage_role (Handler, Value.role);
      if not Value.content.Is_Null then
         Handler.Key_Name ("content");
         Handler.String_Value (Value.content);
      end if;
      if not Value.name.Is_Null then
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
      end if;
      if not Value.tool_call_id.Is_Null then
         Handler.Key_Name ("tool_call_id");
         Handler.String_Value (Value.tool_call_id);
      end if;
      if not Value.tool_calls.Is_Null then
         Handler.Key_Name ("tool_calls");
         Handler.Start_Array;
         for J in 1 .. Value.tool_calls.Length loop
            Output_ChatCompletionMessageToolCall
              (Handler, Value.tool_calls (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_ChatCompletionRequestMessage;

   procedure Output_CreateChatCompletionResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateChatCompletionResponse) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("id");
      Handler.String_Value (Value.id);
      Handler.Key_Name ("choices");
      Handler.Start_Array;
      for J in 1 .. Value.choices.Length loop
         Output_ChatCompletionChoice (Handler, Value.choices (J));
      end loop;
      Handler.End_Array;
      Handler.Key_Name ("created");
      Handler.Integer_Value (Value.created);
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if not Value.system_fingerprint.Is_Null then
         Handler.Key_Name ("system_fingerprint");
         Handler.String_Value (Value.system_fingerprint);
      end if;
      Handler.Key_Name ("object");
      Handler.String_Value ("chat.completion");
      if Value.usage.Is_Set then
         Handler.Key_Name ("usage");
         Output_CompletionUsage (Handler, Value.usage.Value);
      end if;
      Handler.End_Object;
   end Output_CreateChatCompletionResponse;

   procedure Output_CompletionUsage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CompletionUsage)
   is
      procedure Output_CompletionUsage_completion_tokens_details
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : CompletionUsage_completion_tokens_details) is
      begin
         Handler.Start_Object;
         if Value.accepted_prediction_tokens.Is_Set then
            Handler.Key_Name ("accepted_prediction_tokens");
            Handler.Integer_Value (Value.accepted_prediction_tokens.Value);
         end if;
         if Value.audio_tokens.Is_Set then
            Handler.Key_Name ("audio_tokens");
            Handler.Integer_Value (Value.audio_tokens.Value);
         end if;
         if Value.reasoning_tokens.Is_Set then
            Handler.Key_Name ("reasoning_tokens");
            Handler.Integer_Value (Value.reasoning_tokens.Value);
         end if;
         if Value.rejected_prediction_tokens.Is_Set then
            Handler.Key_Name ("rejected_prediction_tokens");
            Handler.Integer_Value (Value.rejected_prediction_tokens.Value);
         end if;
         Handler.End_Object;
      end Output_CompletionUsage_completion_tokens_details;

      procedure Output_CompletionUsage_prompt_tokens_details
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : CompletionUsage_prompt_tokens_details) is
      begin
         Handler.Start_Object;
         if Value.audio_tokens.Is_Set then
            Handler.Key_Name ("audio_tokens");
            Handler.Integer_Value (Value.audio_tokens.Value);
         end if;
         if Value.cached_tokens.Is_Set then
            Handler.Key_Name ("cached_tokens");
            Handler.Integer_Value (Value.cached_tokens.Value);
         end if;
         Handler.End_Object;
      end Output_CompletionUsage_prompt_tokens_details;

   begin
      Handler.Start_Object;
      Handler.Key_Name ("completion_tokens");
      Handler.Integer_Value (Value.completion_tokens);
      Handler.Key_Name ("prompt_tokens");
      Handler.Integer_Value (Value.prompt_tokens);
      Handler.Key_Name ("total_tokens");
      Handler.Integer_Value (Value.total_tokens);
      if Value.completion_tokens_details.Is_Set then
         Handler.Key_Name ("completion_tokens_details");
         Output_CompletionUsage_completion_tokens_details
           (Handler, Value.completion_tokens_details.Value);
      end if;
      if Value.prompt_tokens_details.Is_Set then
         Handler.Key_Name ("prompt_tokens_details");
         Output_CompletionUsage_prompt_tokens_details
           (Handler, Value.prompt_tokens_details.Value);
      end if;
      Handler.End_Object;
   end Output_CompletionUsage;

   procedure Output_FunctionObject
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : FunctionObject) is
   begin
      Handler.Start_Object;
      if not Value.description.Is_Null then
         Handler.Key_Name ("description");
         Handler.String_Value (Value.description);
      end if;
      Handler.Key_Name ("name");
      Handler.String_Value (Value.name);
      if Value.parameters.Is_Set then
         Handler.Key_Name ("parameters");
         Output_FunctionParameters (Handler, Value.parameters.Value);
      end if;
      if Value.strict then
         Handler.Key_Name ("strict");
         Handler.Boolean_Value (Value.strict);
      end if;
      Handler.End_Object;
   end Output_FunctionObject;

   procedure Output_ResponseFormatJsonSchemaSchema
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonSchemaSchema) is
   begin
      Output_Any_Value (Handler, Value);
   end Output_ResponseFormatJsonSchemaSchema;

   procedure Output_ResponseFormatJsonSchema
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonSchema)
   is
      procedure Output_ResponseFormatJsonSchema_json_schema
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ResponseFormatJsonSchema_json_schema) is
      begin
         Handler.Start_Object;
         if not Value.description.Is_Null then
            Handler.Key_Name ("description");
            Handler.String_Value (Value.description);
         end if;
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
         if Value.schema.Is_Set then
            Handler.Key_Name ("schema");
            Output_ResponseFormatJsonSchemaSchema
              (Handler, Value.schema.Value);
         end if;
         if Value.strict then
            Handler.Key_Name ("strict");
            Handler.Boolean_Value (Value.strict);
         end if;
         Handler.End_Object;
      end Output_ResponseFormatJsonSchema_json_schema;

   begin
      Handler.Start_Object;
      Handler.Key_Name ("type");
      Handler.String_Value ("json_schema");
      Handler.Key_Name ("json_schema");
      Output_ResponseFormatJsonSchema_json_schema (Handler, Value.json_schema);
      Handler.End_Object;
   end Output_ResponseFormatJsonSchema;

end Chat_Completions_API.Types.Outputs;
