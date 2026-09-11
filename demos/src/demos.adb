--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------
--
--  A minimal demo talking to a local, OpenAI-compatible server (tested
--  against `llama-server`), showing a plain chat completion and a
--  tool-calling round trip.
------------------------------------------------------------------

pragma Ada_2022;

with Ada.Wide_Wide_Text_IO;
with VSS.JSON.Streams;
with VSS.Strings.Conversions;

with Chat_Completions_API.Chats;
with Chat_Completions_API.Types;

with HTTP_Requests;

procedure Demos is

   Model : constant VSS.Strings.Virtual_String := "local-model";

   Get_Weather_Parameters :
     constant Chat_Completions_API.Types.FunctionParameters :=
       [(Kind => VSS.JSON.Streams.Start_Object),
        (VSS.JSON.Streams.Key_Name, "type"),
        (VSS.JSON.Streams.String_Value, "object"),
        (VSS.JSON.Streams.Key_Name, "properties"),
        (Kind => VSS.JSON.Streams.Start_Object),
        (VSS.JSON.Streams.Key_Name, "location"),
        (Kind => VSS.JSON.Streams.Start_Object),
        (VSS.JSON.Streams.Key_Name, "type"),
        (VSS.JSON.Streams.String_Value, "string"),
        (VSS.JSON.Streams.Key_Name, "description"),
        (VSS.JSON.Streams.String_Value,
         "City and country, e.g. Paris, France"),
        (Kind => VSS.JSON.Streams.End_Object),
        (Kind => VSS.JSON.Streams.End_Object),
        (VSS.JSON.Streams.Key_Name, "required"),
        (Kind => VSS.JSON.Streams.Start_Array),
        (VSS.JSON.Streams.String_Value, "location"),
        (Kind => VSS.JSON.Streams.End_Array),
        (Kind => VSS.JSON.Streams.End_Object)];

   Get_Weather : constant Chat_Completions_API.Types.ChatCompletionTool :=
     (a_function =>
        (name        => "get_weather",
         description => "Get the current weather for a location",
         parameters  => (Is_Set => True, Value => Get_Weather_Parameters),
         strict      => False));

   procedure Print
     (Message : Chat_Completions_API.Types.ChatCompletionResponseMessage);

   -----------
   -- Print --
   -----------

   procedure Print
     (Message : Chat_Completions_API.Types.ChatCompletionResponseMessage) is
   begin
      if not Message.content.Is_Empty then
         Ada.Wide_Wide_Text_IO.Put ("Content: ");
         Ada.Wide_Wide_Text_IO.Put_Line
           (VSS.Strings.Conversions.To_Wide_Wide_String (Message.content));
      end if;

      for J in 1 .. Message.tool_calls.Length loop
         Ada.Wide_Wide_Text_IO.Put ("Tool call: ");
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String
              (Message.tool_calls (J).a_function.name));
         Ada.Wide_Wide_Text_IO.Put (" (");
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String
              (Message.tool_calls (J).a_function.arguments));
         Ada.Wide_Wide_Text_IO.Put (") [");
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String
              (Message.tool_calls (J).id));
         Ada.Wide_Wide_Text_IO.Put_Line ("]");
      end loop;
   end Print;

   Server   : Chat_Completions_API.Server;
   HTTP     : aliased HTTP_Requests.HTTP_Request;
   Response : Chat_Completions_API.Types.CreateChatCompletionResponse;
   Ok       : Boolean;
   Messages : Chat_Completions_API.Types.ChatCompletionRequestMessage_Vector :=
     [(role    => Chat_Completions_API.Types.user,
       content => "What's the weather like in Kyiv?",
       others  => <>)];
begin
   Server.Set_Request_Handler (HTTP'Unchecked_Access);
   --  Server.Set_URL ("http://localhost:8080/v1/chat/completions");
   --  (the default already points there -- adjust for a remote server)

   Chat_Completions_API.Chats.Chat
     (Server,
      Model    => Model,
      Messages => Messages,
      Tools    => [Get_Weather],
      Response => Response,
      Success  => Ok);

   if not Ok or else Response.choices.Length = 0 then
      Ada.Wide_Wide_Text_IO.Put_Line ("Request failed.");
      return;
   end if;

   Ada.Wide_Wide_Text_IO.Put_Line ("Response:");
   Print (Response.choices (1).message);

   Messages.Append
     ((role       => Chat_Completions_API.Types.assistant,
       tool_calls => Response.choices (1).message.tool_calls,
       others     => <>));

   for J in 1 .. Response.choices (1).message.tool_calls.Length loop
      Messages.Append
        ((role         => Chat_Completions_API.Types.tool,
          tool_call_id => Response.choices (1).message.tool_calls (J).id,
          content      => "15 C, light rain",
          others       => <>));
   end loop;

   if Response.choices (1).message.tool_calls.Length > 0 then
      declare
         Response : Chat_Completions_API.Types.CreateChatCompletionResponse;
      begin
         Chat_Completions_API.Chats.Chat
           (Server,
            Model    => Model,
            Messages => Messages,
            Tools    => [Get_Weather],
            Response => Response,
            Success  => Ok);

         if Ok and then Response.choices.Length > 0 then
            Ada.Wide_Wide_Text_IO.Put_Line ("Response[2]:");
            Print (Response.choices (1).message);
         end if;
      end;
   end if;
end Demos;
