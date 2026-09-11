--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

package body Chat_Completions_API.Chats is

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
      Success               : out Boolean) is
   begin
      Self.Chat
        (Chat_Completions_API.Types.CreateChatCompletionRequest'
           (model                 => Model,
            messages              => Messages,
            tools                 => Tools,
            tool_choice           => Tool_Choice,
            parallel_tool_calls   => Parallel_Tool_Calls,
            temperature           => Temperature,
            top_p                 => Top_P,
            max_completion_tokens => Max_Completion_Tokens,
            n                     => N,
            seed                  => Seed,
            frequency_penalty     => Frequency_Penalty,
            presence_penalty      => Presence_Penalty,
            response_format       => Response_Format,
            stream                => False,
            logprobs              => Logprobs,
            top_logprobs          => Top_Logprobs,
            user                  => User),
         Response,
         Success);
   end Chat;

end Chat_Completions_API.Chats;
