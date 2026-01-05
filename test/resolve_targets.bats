#!/usr/bin/env bats

setup() {
	bats_load_library 'bats-assert'
	bats_load_library 'bats-support'
	DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
	PATH="$DIR/../src:$PATH"
	TEST_WORK_DIR="$BATS_TEST_TMPDIR/test_$BATS_TEST_NUMBER"
	mkdir -p "$TEST_WORK_DIR"
	cd "$TEST_WORK_DIR" || exit 1
}

@test "expand: [specific] short names expand to slides/ paths" {
	run expand_manual_targets.sh <<<"topic1 topic2"
	assert_success
	assert_output "slides/topic1 slides/topic2"
}

@test "expand: [all] finds all directories" {
	mkdir -p slides/one slides/two
	run expand_manual_targets.sh <<<"all"
	output=$(echo "$output" | tr ' ' '\n' | sort | tr '\n' ' ')
	assert_success
	assert_output "slides/one slides/two"
}

@test "filter: [valid] keeps folders with main.md" {
	mkdir -p slides/ok
	touch slides/ok/main.md

	run filter_build_targets.sh <<<"slides/ok"
	assert_success
	assert_output "slides/ok"
}

@test "filter: [invalid] remove undifined folder" {
	run filter_build_targets.sh <<<"slides/undifined"
	assert_success
	assert_output ""
}

@test "filter: [invalid] remove folder outside slides/" {
	mkdir -p config/one
	touch config/one/main.md

	run filter_build_targets.sh <<<"config/one"
	assert_success
	assert_output ""
}

@test "filter: [invalid] remove folder without main.md" {
	mkdir -p slides/empty_dir

	run filter_build_targets.sh <<<"slides/empty_dir"
	assert_success
	assert_output ""
}

@test "filter: [exclude] remove slides/utl" {
	mkdir -p slides/utl
	touch slides/utl/main.md

	run filter_build_targets.sh <<<"slides/utl"
	assert_success
	assert_output ""
}

@test "pipeline: input -> expand -> filter -> output" {
	mkdir -p slides/topic1 slides/topic2 slides/utl
	touch slides/topic1/main.md slides/topic2/main.md slides/utl/main.md

	# topic1 topic2 utl dummy
	# -> slides/topic1 slides/utl slides/dummy
	# -- utl is excluded, dummy does not exist --
	# -> slides/topic1 slides/topic2
	run bash -c "echo 'topic1 topic2 utl dummy' \
        | expand_manual_targets.sh \
        | filter_build_targets.sh"

	assert_success
	assert_output "slides/topic1 slides/topic2"
}
