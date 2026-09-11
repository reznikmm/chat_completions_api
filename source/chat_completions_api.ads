--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.IRIs;
with VSS.Strings;

limited with Chat_Completions_API.HTTP_Requests;
limited with Chat_Completions_API.Types;

package Chat_Completions_API is

   type Server is tagged limited private;

   procedure Chat
     (Self     : in out Server'Class;
      Request  : Chat_Completions_API.Types.CreateChatCompletionRequest;
      Response : out Chat_Completions_API.Types.CreateChatCompletionResponse;
      Success  : out Boolean);
   --  Send a chat completion request to the `/v1/chat/completions`
   --  endpoint and parse the response.

   procedure Set_URL (Self : in out Server'Class; Value : VSS.IRIs.IRI);

   procedure Set_URL
     (Self : in out Server'Class; Value : VSS.Strings.Virtual_String);

   procedure Set_API_Key
     (Self : in out Server'Class; Value : VSS.Strings.Virtual_String);
   --  Set the API key sent as `Authorization: Bearer <Value>`. Most
   --  OpenAI-compatible servers (e.g. llama.cpp) don't require one.

   type HTTP_Request_Access is
     access all Chat_Completions_API.HTTP_Requests.HTTP_Request'Class
   with Storage_Size => 0;

   procedure Set_Request_Handler
     (Self : in out Server'Class; Value : not null HTTP_Request_Access);

private

   type Server is tagged limited record
      HTTP    : HTTP_Request_Access;
      URL     : VSS.IRIs.IRI :=
        VSS.IRIs.To_IRI ("http://localhost:8080/v1/chat/completions");
      API_Key : VSS.Strings.Virtual_String;
   end record;

end Chat_Completions_API;
