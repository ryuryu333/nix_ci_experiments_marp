#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Expand manual build targets to full path list
# stdin: space-separated list of folder-name or special keyword
#   e.g. "topic1 topic2 ..." or "all"
# stdout: space-separated list of valid folders (2 levels deep)
#   e.g. "slides/topic1 slides/topic2 ..." or "slides/topic1 slides/topic2 slides/..."
# ------------------------------------------------------------------

function expand_all() {
	find slides -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0
}

function expand_specific_list() {
	local input_targets="$1"
	local result=""

	# Expand each item to correct path
	# e.g. topic1 slides/topic2 -> slides/topic1 slides/topic2
	for item in $input_targets; do
		if [[ "$item" == slides/* ]]; then
			result="$result $item"
		else
			result="$result slides/$item"
		fi
	done

	echo "$result" | xargs
}

function main() {
	local input
	input=$(cat)
	case "$input" in
	"")
		return 0
		;;
	"all")
		expand_all
		;;
	*)
		expand_specific_list "$input"
		;;
	esac
}

main "$@"
