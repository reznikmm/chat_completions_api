--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

with VSS.JSON.Pull_Readers.Simple;
with VSS.JSON.Push_Writers;
with VSS.String_Vectors;
with VSS.Strings.Conversions;
with VSS.Text_Streams.Memory_UTF8_Input;
with VSS.Text_Streams.Memory_UTF8_Output;

with Chat_Completions_API.Types;
with Chat_Completions_API.Types.Inputs;
with Chat_Completions_API.Types.Outputs;

package body Test_Init is

   procedure Test_Basic_Init (Op : in out Trendy_Test.Operation'Class) is
   begin
      Op.Register (Parallelize => False);

      Op.Assert (3 > 1);
   end Test_Basic_Init;

   procedure Test_Stop_Field (Op : in out Trendy_Test.Operation'Class) is
      use type VSS.Strings.Virtual_String;

      Request  : Chat_Completions_API.Types.CreateChatCompletionRequest;
      Writer   : VSS.JSON.Push_Writers.JSON_Simple_Push_Writer;
      Output   :
        aliased VSS.Text_Streams.Memory_UTF8_Output.Memory_UTF8_Output_Stream;
      Input    :
        aliased VSS.Text_Streams.Memory_UTF8_Input.Memory_UTF8_Input_Stream;
      Reader   : VSS.JSON.Pull_Readers.Simple.JSON_Simple_Pull_Reader;
      Success  : Boolean := True;
      Reparsed : Chat_Completions_API.Types.CreateChatCompletionRequest;
   begin
      Op.Register (Parallelize => False);

      Request.stop.Append (VSS.Strings.Conversions.To_Virtual_String ("a"));
      Request.stop.Append (VSS.Strings.Conversions.To_Virtual_String ("b"));

      Writer.Set_Stream (Output'Unchecked_Access);
      Writer.Start_Document;
      Chat_Completions_API.Types.Outputs.Output_CreateChatCompletionRequest
        (Writer, Request);
      Writer.End_Document;

      Input.Set_Data (Output.Buffer);
      Reader.Set_Stream (Input'Unchecked_Access);
      Reader.Read_Next;
      Success := Reader.Is_Start_Document;
      Reader.Read_Next;
      Chat_Completions_API.Types.Inputs.Input_CreateChatCompletionRequest
        (Reader, Reparsed, Success);

      Op.Assert (Success);
      Op.Assert (Reparsed.stop.Length = 2);
      Op.Assert (Reparsed.stop (1) = "a");
      Op.Assert (Reparsed.stop (2) = "b");
   end Test_Stop_Field;

end Test_Init;
