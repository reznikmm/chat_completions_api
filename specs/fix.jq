## Reduce the (huge) upstream OpenAI OpenAPI spec down to a minimal set of
## schemas covering chat completions and tool/function calling, suitable for
## testing against an OpenAI-compatible server (e.g. llama.cpp).
##
## Simplifications applied on top of the upstream schemas (kept deliberately
## small so it stays readable and matches what llama.cpp actually supports):
##  * "model" is a plain string, not the huge OpenAI model-name enum.
##  * message "content" is plain text only (no multi-part / image / audio
##    content arrays).
##  * only system/user/assistant/tool message roles are kept (drops the
##    deprecated "function" role and the o1-specific "developer" role).
##  * deprecated / cloud-only / multi-modal request options are dropped:
##    function_call, functions, audio, modalities, web_search_options,
##    prediction, reasoning_effort, logit_bias, store, stream_options,
##    service_tier, metadata, max_tokens (superseded by
##    max_completion_tokens).
##  * response message drops annotations, function_call and audio.
##  * streaming (stream: true / SSE) is out of scope for now.

def plain_string: {"type": "string"};

def schema_refs:
  [.. | objects | select(has("$ref")) | .["$ref"]
     | ltrimstr("#/components/schemas/")];

def closure(roots; all_schemas):
  reduce range(0; 2000) as $i
    ({done: {}, todo: roots};
      if (.todo | length) == 0 then .
      else
        .todo[0] as $name
        | .todo |= .[1:]
        | if (.done | has($name)) then .
          else
            (all_schemas[$name]) as $s
            | .done += {($name): $s}
            | (($s // {}) | schema_refs) as $new_refs
            | .todo += ($new_refs - (.done | keys) - .todo)
          end
      end);

(.components.schemas
  # Skip the pointless CreateModelResponseProperties indirection (a
  # single-element allOf wrapping ModelResponseProperties) and reference it
  # directly instead.
  | .CreateChatCompletionRequest.allOf[0] =
      {"$ref": "#/components/schemas/ModelResponseProperties"}

  # --- Trim CreateChatCompletionRequest to the properties we care about ---
  | .CreateChatCompletionRequest.allOf[1].properties |=
      with_entries(select(.key |
        IN("messages", "model", "max_completion_tokens", "frequency_penalty",
           "presence_penalty", "top_logprobs", "response_format", "stream",
           "logprobs", "n", "seed", "tools", "tool_choice",
           "parallel_tool_calls")))
  | .CreateChatCompletionRequest.allOf[1].properties.model = plain_string

  # Likewise, the generator can't turn a $ref to a bare scalar schema (no
  # enum/properties/etc, just `type: boolean`) into a named alias; inline
  # it instead.
  | .CreateChatCompletionRequest.allOf[1].properties.parallel_tool_calls =
      {type: "boolean"}

  # ModelResponseProperties: keep temperature/top_p/user only
  | .ModelResponseProperties.properties |=
      with_entries(select(.key | IN("temperature", "top_p", "user")))

  # tool_choice's oneOf mixes a bare string enum ("none"/"auto"/"required")
  # with an object variant (force one specific named tool) -- a shape the
  # generator can't discriminate (there's no property to key off of for the
  # bare-enum branch). Drop the "force this exact tool" variant and keep
  # just the enum, which covers normal tool-calling usage.
  | .ChatCompletionToolChoiceOption = {
      type: "string",
      description: "Controls which (if any) tool is called by the model.",
      enum: ["none", "auto", "required"]
    }

  # Upstream models each role (system/user/assistant/tool/function/developer)
  # as its own schema, joined by a `oneOf`. Flatten this into a single
  # lenient record instead -- role plus every field any role might use,
  # all but role optional -- mirroring how ollama_api's own ChatMessage
  # works. This both drops the deprecated `function` role and the o1-only
  # `developer` role, and avoids a generator limitation with discriminated
  # union types used as vector elements.
  | .ChatCompletionRequestMessage = {
      type: "object",
      required: ["role"],
      properties: {
        role: {type: "string", enum: ["system", "user", "assistant", "tool"],
               description: "The role of the message author."},
        content: plain_string,
        name: plain_string,
        tool_call_id: plain_string,
        tool_calls: {type: "array",
                     items:
                       {"$ref": "#/components/schemas/ChatCompletionMessageToolCall"}}
      }
    }

  # Response message: drop annotations/function_call/audio
  | .ChatCompletionResponseMessage.properties |=
      del(.annotations, .function_call, .audio)

  # Drop the cloud-only service_tier field from the response too
  | .CreateChatCompletionResponse.properties |= del(.service_tier)

  # The generator can't turn an array of anonymous objects into a vector,
  # only an array of $ref'd (named) schemas. Lift the anonymous "choice"
  # item type into a named definition.
  | .ChatCompletionChoice = .CreateChatCompletionResponse.properties.choices.items
  | .CreateChatCompletionResponse.properties.choices.items =
      {"$ref": "#/components/schemas/ChatCompletionChoice"}

  # Same anonymous-array-item limitation applies to the per-position
  # alternative-tokens list; drop it, it is not needed for a minimal binding.
  | .ChatCompletionTokenLogprob.properties |= del(.top_logprobs)
  | .ChatCompletionTokenLogprob.required -= ["top_logprobs"]

  # The generator can't follow a $ref to a schema that is itself just an
  # array type (it only special-cases inline `type: array` properties or
  # refs to object/enum schemas), so inline the tool_calls array directly
  # instead of going through the named ChatCompletionMessageToolCalls
  # schema.
  | .ChatCompletionResponseMessage.properties.tool_calls =
      {type: "array",
       items: {"$ref": "#/components/schemas/ChatCompletionMessageToolCall"}}

  # response_format is an inline (unnamed) oneOf upstream; the generator
  # can only handle a oneOf/anyOf property through a $ref to a named
  # schema (that's how tool_choice already works via
  # ChatCompletionToolChoiceOption), so give it a name of its own.
  | .ChatCompletionResponseFormatOption = {oneOf: [
      {"$ref": "#/components/schemas/ResponseFormatText"},
      {"$ref": "#/components/schemas/ResponseFormatJsonSchema"},
      {"$ref": "#/components/schemas/ResponseFormatJsonObject"}
    ]}
  | .CreateChatCompletionRequest.allOf[1].properties.response_format =
      {"$ref": "#/components/schemas/ChatCompletionResponseFormatOption"}
) as $s

| closure(
    ["CreateChatCompletionRequest", "CreateChatCompletionResponse"];
    $s
  ) as $c

| {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Chat Completions API Schemas",
    "definitions": $c.done
  }

# gen_json expects internal refs to point at "#/definitions/...".
| walk(
    if (type == "object" and has("$ref")) then
      .["$ref"] |= sub("^#/components/schemas/"; "#/definitions/")
    else
      .
    end)
