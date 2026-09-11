--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with VSS.JSON.Pull_Readers.Simple;
with VSS.JSON.Push_Writers;
with VSS.Stream_Element_Vectors;
with VSS.Text_Streams.Memory_UTF8_Input;
with VSS.Text_Streams.Memory_UTF8_Output;

with Chat_Completions_API.HTTP_Requests;
with Chat_Completions_API.Types.Inputs;
with Chat_Completions_API.Types.Outputs;

package body Chat_Completions_API is

   use type VSS.Strings.Virtual_String;

   ----------
   -- Chat --
   ----------

   procedure Chat
     (Self     : in out Server'Class;
      Request  : Chat_Completions_API.Types.CreateChatCompletionRequest;
      Response : out Chat_Completions_API.Types.CreateChatCompletionResponse;
      Success  : out Boolean)
   is
      Writer : VSS.JSON.Push_Writers.JSON_Simple_Push_Writer;
      Output :
        aliased VSS.Text_Streams.Memory_UTF8_Output.Memory_UTF8_Output_Stream;
      Data   : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Input  :
        aliased VSS.Text_Streams.Memory_UTF8_Input.Memory_UTF8_Input_Stream;
      Reader : VSS.JSON.Pull_Readers.Simple.JSON_Simple_Pull_Reader;
      Code   : Natural;
   begin
      Writer.Set_Stream (Output'Unchecked_Access);
      Writer.Start_Document;
      Chat_Completions_API.Types.Outputs.Output_CreateChatCompletionRequest
        (Writer, Request);
      Writer.End_Document;
      Self.HTTP.Post
        (URL           => Self.URL,
         Content_Type  => "application/json",
         Authorization =>
           VSS.Strings.To_Virtual_String ("Bearer ") & Self.API_Key,
         Output        => Output.Buffer,
         Response      => Data,
         Status_Code   => Code);

      if Code = 200 then
         Input.Set_Data (Data);
         Reader.Set_Stream (Input'Unchecked_Access);
         Reader.Read_Next;
         Success := Reader.Is_Start_Document;
         Reader.Read_Next;
         Chat_Completions_API.Types.Inputs.Input_CreateChatCompletionResponse
           (Reader, Response, Success);
      else
         Success := False;
      end if;
   end Chat;

   ------------------
   -- Set_API_Key --
   ------------------

   procedure Set_API_Key
     (Self : in out Server'Class; Value : VSS.Strings.Virtual_String) is
   begin
      Self.API_Key := Value;
   end Set_API_Key;

   -------------------------
   -- Set_Request_Handler --
   -------------------------

   procedure Set_Request_Handler
     (Self : in out Server'Class; Value : not null HTTP_Request_Access) is
   begin
      Self.HTTP := Value;
   end Set_Request_Handler;

   -------------
   -- Set_URL --
   -------------

   procedure Set_URL (Self : in out Server'Class; Value : VSS.IRIs.IRI) is
   begin
      Self.URL := Value;
   end Set_URL;

   -------------
   -- Set_URL --
   -------------

   procedure Set_URL
     (Self : in out Server'Class; Value : VSS.Strings.Virtual_String) is
   begin
      Self.Set_URL (VSS.IRIs.To_IRI (Value));
   end Set_URL;

end Chat_Completions_API;
