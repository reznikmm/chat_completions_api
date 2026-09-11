# SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
#
# SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception

URL="https://raw.githubusercontent.com/openai/openai-openapi/refs/heads/manual_spec/openapi.yaml"

GEN_JSON ?= gen_json

fetch:
		curl -L $(URL) |\
		python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout)' |\
		jq --from-file fix.jq \
		> schema.json

generate:
		$(GEN_JSON) --header-file header.adt --root-package Chat_Completions_API.Types schema.json > /tmp/all.txt
		gnatchop /tmp/all.txt ../source/generated
		gnatformat -P ../gnat/chat_completions_api.gpr ../source/generated/*.ad[sb]
