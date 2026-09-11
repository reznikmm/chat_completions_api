--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Chat_Completions_API.Types;

package Chat_Completions_API.Chats is

   procedure Chat
     (Self                  : in out Server'Class;
      Model                 : VSS.Strings.Virtual_String;
      Messages              :
        Chat_Completions_API.Types.ChatCompletionRequestMessage_Vector;
      Tools                 :
        Chat_Completions_API.Types.ChatCompletionTool_Vector := [];
      Tool_Choice           :
        Chat_Completions_API.Types.Optional_ChatCompletionToolChoiceOption :=
          (Is_Set => False);
      Parallel_Tool_Calls   : Boolean := False;
      Temperature           : Chat_Completions_API.Types.Optional_Float_64 :=
        (Is_Set => False);
      Top_P                 : Chat_Completions_API.Types.Optional_Float_64 :=
        (Is_Set => False);
      Max_Completion_Tokens : Chat_Completions_API.Types.Optional_Integer_64 :=
        (Is_Set => False);
      N                     : Chat_Completions_API.Types.Optional_Integer_64 :=
        (Is_Set => False);
      Seed                  : Chat_Completions_API.Types.Optional_Integer_64 :=
        (Is_Set => False);
      Frequency_Penalty     : Chat_Completions_API.Types.Optional_Float_64 :=
        (Is_Set => False);
      Presence_Penalty      : Chat_Completions_API.Types.Optional_Float_64 :=
        (Is_Set => False);
      Response_Format       :
        Chat_Completions_API
          .Types
          .Optional_ChatCompletionResponseFormatOption := (Is_Set => False);
      Logprobs              : Boolean := False;
      Top_Logprobs          : Chat_Completions_API.Types.Optional_Integer_64 :=
        (Is_Set => False);
      User                  : VSS.Strings.Virtual_String :=
        VSS.Strings.Empty_Virtual_String;
      Response              :
        out Chat_Completions_API.Types.CreateChatCompletionResponse;
      Success               : out Boolean);
   --  Generate the next chat completion for a conversation, optionally
   --  offering the model a list of tools (function calling).
   --
   --  * @param Model - Model name
   --  * @param Messages - Chat history so far (each with a role and content)
   --  * @param Tools - Optional list of function tools the model may call
   --  * @param Tool_Choice - "none", "auto" or "required"
   --  * @param Parallel_Tool_Calls - Whether to allow calling several tools
   --    at once
   --  * @param Temperature - Sampling temperature, between 0 and 2
   --  * @param Top_P - Nucleus sampling parameter
   --  * @param Max_Completion_Tokens - Upper bound on generated tokens
   --  * @param N - How many choices to generate
   --  * @param Seed - Best-effort deterministic sampling seed
   --  * @param Frequency_Penalty - Penalize tokens by existing frequency
   --  * @param Presence_Penalty - Penalize tokens that already appeared
   --  * @param Response_Format - Plain text, JSON mode or a JSON Schema
   --  * @param Logprobs - Whether to return output token log probabilities
   --  * @param Top_Logprobs - Number of most likely tokens to report per
   --    position when Logprobs is enabled
   --  * @param User - Opaque end-user identifier

end Chat_Completions_API.Chats;
