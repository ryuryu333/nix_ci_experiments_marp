#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Filter build targets
# stdin: space-separated list of folders (2 levels deep)
#   e.g. "slides/topic1 slides/utl slides/no_contain_main.md ..."
# stdout: space-separated list of valid folders (2 levels deep)
#   e.g. "slides/topic1 ..."
# logic: exclude specific folders, ensure main.md exists
# NOTE: folder names do not contain spaces
# ------------------------------------------------------------------

function main() {
	local exclude="slides/utl"
	local required_file="main.md"
	local input
	input=$(cat)

	local targets=()

	for folder in $input; do
		if [[ ! "$folder" =~ slides/ ]]; then
			continue
		fi
		if [ ! -f "$folder/$required_file" ]; then
			continue
		fi
		if [ "$folder" == "$exclude" ]; then
			continue
		fi
		targets+=("$folder")
	done

	echo "${targets[*]}"
}

main "$@"
