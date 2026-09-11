# Chat_Completions_API

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/chat_completions_api.json)](https://alire.ada.dev/crates/chat_completions_api.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/chat_completions_api)](https://api.reuse.software/info/github.com/reznikmm/chat_completions_api)

> Ada library for talking to OpenAI-compatible Chat Completions APIs
> (OpenAI, llama.cpp server, vLLM, ...), including chat and tool calling.

## Features

- **Chat Completions client in Ada**
- **Tool/function calling support**
- **Custom HTTP request handler support**
- **JSON-based communication**
- **Demo application included**

**Limitations**:
- Streaming (`stream: true`, Server-Sent Events) is not implemented yet.

## Repository Structure

- `source/` — Hand-written library sources
- `source/generated/` — Types generated from `specs/schema.json`
- `specs/` — JSON Schema (trimmed from the upstream OpenAPI spec) and the
  `Makefile` used to (re)generate `source/generated`
- `demos/` — Demo project using the library against a local llama.cpp server
- `gnat/` — GPR project files
- `config/` — Configuration and build files
- `alire.toml` — Alire crate manifest
- `LICENSES/` — License information

## Installation

To install the library using the Alire package manager:

```sh
alr with chat_completions_api --use=https://github.com/reznikmm/chat_completions_api.git
```

## Usage Example

```ada
declare
   Server   : Chat_Completions_API.Server;
   Response : Chat_Completions_API.Types.CreateChatCompletionResponse;
   Success  : Boolean;
begin
   Server.Set_Request_Handler (HTTP'Unchecked_Access);
   Server.Set_URL ("http://localhost:8080/v1/chat/completions");

   Chat_Completions_API.Chats.Chat
     (Server,
      Model    => "local-model",
      Messages =>
        [(Role    => Chat_Completions_API.Types.user,
          Content => "Why is Ada so popular?",
          others  => <>)],
      Response => Response,
      Success  => Success);

   if Success then
      --  Process Response
      null;
   end if;
end;
```

See the `demos/` folder for a complete working example, including tool
registration and custom HTTP requests.

## Demos

The `demos` folder contains a sample application demonstrating:
- Registering and using tools (function calling)
- Making chat requests against a local llama.cpp server
- Handling responses and tool calls

To build and run the demo:

```sh
cd demos
alr build
./bin/demos
```

## Maintainer

Max Reznik <reznikmm@gmail.com>

## License

Apache-2.0 WITH LLVM-exception
