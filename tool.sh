#!/usr/bin/env sh

# --- Printing related

println () {
    echo -e "${1}"
}

colorize () {
    local str=${1}

    # TODO
    local color=${2}

    println "$str"
}


# --- JSON parsing related

count_action () {
    local output="${1}"
    local action="${2}"
    echo $output | jq -r '[.[] | select(.Action == "'"$action"'")] | length'
}

get_tests_by_action () {
    local output="${1}"
    local action="${2}"
    echo $output | jq -r '[.[] | select(.Action == "'"$action"'")]'
}

test_summary () {
    local output="${1}"

    pass_count=$(count_action "$output" "pass")
    fail_count=$(count_action "$output" "fail")
    skip_count=$(count_action "$output" "skip")

    local result=""

    local color="green"
    if [ $fail_count -gt 0 ]; then
        color="red"
    fi

    result+=$(colorize "$pass_count PASS, $fail_count FAIL, $skip_count SKIP" "$color")
    echo $result
}

output=$($cmd_go_test | $cmd_jq)

get_tests () {
    local output="${1}"
    echo $output | jq -c '[.[] | select(.Test != null)]'
}

gospec () {
    cmd_go_test="go test -json ./..."
    cmd_jq="jq -c --slurp ."

    output=$($cmd_go_test | $cmd_jq)

    output_tests=$(get_tests "$output")

    echo $(test_summary "$output_tests")

    fail_count=$(count_action "$output" "fail")

    if [ $fail_count -gt 0 ]; then
        println
        println "Failing tests:"
        println

        get_tests_by_action "$output_tests" "fail" | jq -r 'sort_by(.Package) | .[].Test'
    fi
}

gospec
