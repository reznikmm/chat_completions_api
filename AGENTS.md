# AGENTS.md

## Purpose

Chat_Completions_API is an Ada library for talking to OpenAI-compatible
Chat Completions HTTP APIs (OpenAI itself, llama.cpp server, vLLM, etc.),
including chat messages and tool/function calling.

## Repository Map

- `source/`: Hand-written library logic (`Chat_Completions_API.*` packages)
- `source/generated/`: Ada types generated from `specs/schema.json` by
  `gen_json` (do not edit manually, regenerate via `specs/Makefile`)
- `specs/`: JSON Schema fetched/trimmed from the upstream OpenAPI spec and
  the `Makefile` that (re)generates `source/generated`
- `demos/`: Standalone demo crate exercising the library against a local
  llama.cpp server
- `gnat/`: GPR project files
- `testsuite/`: Separate test suite crate
- `config/`: Build-time configuration artifacts written by Alire (do not edit manually)
- `.obj/`, `.lib/`: Build outputs (do not edit manually)

## Ground Rules

- Don't suppress exception with `null;` exception handler
   (one exception is `Libadalang.Common.Property_Error`).
- Don't introduce extra (sub-)type conversions, like Integer to Natural.
- Preserve existing style and naming conventions in nearby code. Don't use abbreviations.

## Build And Test Commands

Run from repository root unless noted otherwise.

- Compile core library:
  - `alr build`
- Compile/check one file (`<unit>.adb`):
  - `alr exec -- gprbuild -q -f -c -u -gnatc -P gnat/chat_completions_api.gpr <unit>.adb '-cargs:ada' -gnatef`
- Fix code style warnings, force code style after edit:
  - `alr exec -- gnatformat --charset=utf-8 --no-subprojects -P gnat/chat_completions_api.gpr`
- Build and run testsuite:
  - `alr -C testsuite/ run`
- Regenerate types from the JSON Schema:
  - `cd specs && make generate`

## Change Workflow For Agents

1. Read relevant package spec/body before editing. Read `*.adb` only if reading of corresponding `*.ads` is not enough.
2. Implement the smallest viable patch.
3. Re-run compile check for touched units.
4. Run targeted runtime/test command when behavior changes.
5. Report exactly what changed and what was validated.

## Ada-Specific Notes

- Use predefined Ada container packages
  (for example, `Ada.Containers.Hashed_Sets`). Don't use Indefinite containers.
- Use Ada 2022 syntax if you can.

## Output And Error Handling Expectations

- Diagnostics should be actionable and include path/context when possible.

## When Unsure

- Prefer conservative changes.
- Ask for clarification before large architectural rewrites.
- Document assumptions in the final update.
