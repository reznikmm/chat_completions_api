--
--  Copyright (c) 2026, OpenAI
--
--  SPDX-License-Identifier: MIT
--

with VSS.JSON.Pull_Readers;

package Chat_Completions_API.Types.Inputs is

   procedure Input_ChatCompletionChoice_finish_reason
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionChoice_finish_reason;
      Success : in out Boolean);

   procedure Input_ChatCompletionToolChoiceOption
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionToolChoiceOption;
      Success : in out Boolean);

   procedure Input_ChatCompletionRequestMessage_role
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionRequestMessage_role;
      Success : in out Boolean);

   procedure Input_ResponseFormatText
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatText;
      Success : in out Boolean);

   procedure Input_ChatCompletionMessageToolCall
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionMessageToolCall;
      Success : in out Boolean);

   procedure Input_ChatCompletionTokenLogprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionTokenLogprob;
      Success : in out Boolean);

   procedure Input_ChatCompletionChoice
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionChoice;
      Success : in out Boolean);

   procedure Input_ChatCompletionResponseFormatOption
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionResponseFormatOption;
      Success : in out Boolean);

   procedure Input_CreateChatCompletionRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateChatCompletionRequest;
      Success : in out Boolean);

   procedure Input_FunctionParameters
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out FunctionParameters;
      Success : in out Boolean);

   procedure Input_ResponseFormatJsonObject
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonObject;
      Success : in out Boolean);

   procedure Input_ChatCompletionResponseMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionResponseMessage;
      Success : in out Boolean);

   procedure Input_ModelResponseProperties
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelResponseProperties;
      Success : in out Boolean);

   procedure Input_ChatCompletionTool
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionTool;
      Success : in out Boolean);

   procedure Input_ChatCompletionRequestMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatCompletionRequestMessage;
      Success : in out Boolean);

   procedure Input_CreateChatCompletionResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateChatCompletionResponse;
      Success : in out Boolean);

   procedure Input_CompletionUsage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CompletionUsage;
      Success : in out Boolean);

   procedure Input_FunctionObject
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out FunctionObject;
      Success : in out Boolean);

   procedure Input_ResponseFormatJsonSchemaSchema
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonSchemaSchema;
      Success : in out Boolean);

   procedure Input_ResponseFormatJsonSchema
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ResponseFormatJsonSchema;
      Success : in out Boolean);

end Chat_Completions_API.Types.Inputs;
