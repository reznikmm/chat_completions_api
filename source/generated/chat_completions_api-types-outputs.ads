
--
--  Copyright (c) 2026, OpenAI
--
--  SPDX-License-Identifier: MIT
--

with VSS.JSON.Content_Handlers;

package Chat_Completions_API.Types.Outputs is

   procedure Output_ChatCompletionChoice_finish_reason
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionChoice_finish_reason);

   procedure Output_ChatCompletionToolChoiceOption
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionToolChoiceOption);

   procedure Output_ChatCompletionRequestMessage_role
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionRequestMessage_role);

   procedure Output_ResponseFormatText
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatText);

   procedure Output_ChatCompletionMessageToolCall
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionMessageToolCall);

   procedure Output_ChatCompletionTokenLogprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionTokenLogprob);

   procedure Output_ChatCompletionChoice
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionChoice);

   procedure Output_ChatCompletionResponseFormatOption
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionResponseFormatOption);

   procedure Output_CreateChatCompletionRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateChatCompletionRequest);

   procedure Output_FunctionParameters
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : FunctionParameters);

   procedure Output_ResponseFormatJsonObject
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonObject);

   procedure Output_ChatCompletionResponseMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionResponseMessage);

   procedure Output_ModelResponseProperties
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelResponseProperties);

   procedure Output_ChatCompletionTool
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionTool);

   procedure Output_ChatCompletionRequestMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatCompletionRequestMessage);

   procedure Output_CreateChatCompletionResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateChatCompletionResponse);

   procedure Output_CompletionUsage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CompletionUsage);

   procedure Output_FunctionObject
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : FunctionObject);

   procedure Output_ResponseFormatJsonSchemaSchema
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonSchemaSchema);

   procedure Output_ResponseFormatJsonSchema
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ResponseFormatJsonSchema);

end Chat_Completions_API.Types.Outputs;
