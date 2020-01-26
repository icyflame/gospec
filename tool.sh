#!/bin/bash

# --- Printing related

println () {
    echo -e "${1}"
}

# gist with the original color table code:
# https://gist.github.com/elliotlarson/a22fab0b1aff1b5cc742273ac8ed196f
# setaf color table:
# https://unix.stackexchange.com/a/269085/36994
initialize_colors () {
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    COLOR_RESET=$(tput sgr0)
    BOLD=$(tput bold)
}

colorize () {
    local str=${1}

    local color=${2:-${COLOR_RESET}}

    println "${color}$str${COLOR_RESET}"
}


# --- JSON parsing related

count_action () {
    local output="${1}"
    local action="${2}"
    get_by_action "$output" "$action" | jq -r '. | length'
}

get_by_action () {
    local output="${1}"
    local action="${2}"
    echo "$output" | jq -r '[.[] | select(.Action == "'"$action"'")]'
}

get_tests () {
    local output="${1}"
    echo "$output" | jq -c '[.[] | select(.Test != null)]'
}

get_by_test_and_action () {
    local output="${1}"
    local test_name="${2}"
    local action="${3}"
    echo "$output" | \
        jq '[.[] | select(.Test == "'"$test_name"'") | select(.Action == "'"$action"'")]'
}


# --- Printing various parts of the output

test_summary () {
    local output="${1}"

    pass_count=$(count_action "$output" "pass")
    fail_count=$(count_action "$output" "fail")
    skip_count=$(count_action "$output" "skip")

    local result=""

    local color="${GREEN}"
    if [ $fail_count -gt 0 ]; then
        color="${RED}"
    fi

    result+=$(colorize "$pass_count PASS, $fail_count FAIL, $skip_count SKIP" "${color}")
    echo $result
}

test_list_by_pkg () {
    local output="${1}"
    local action="${2}"
    local output_required="${3}"
    get_by_action "$output" "$action" | \
        for failed_package in $(jq -c 'group_by(.Package) | .[]'); do
            package_name=$(echo "$failed_package" | jq -r '[.[].Package] | unique | .[0]')
            println
            colorize "$package_name" "$BLUE"
            echo "$failed_package" | \
                for test_name in $(jq -r 'sort_by(.Test) | reverse | .[].Test'); do
                    colorize "\t$test_name" "$RED"

                    if [ -n "$output_required" ]; then
                        local action="output";
                        get_by_test_and_action "$output" "$test_name" "output" | \
                            jq -r '.[].Output | select(test("^\\s*(---|===) (SKIP|RUN|PAUSE|CONT|PASS|FAIL)") | not) | sub("\\n"; "")'
                    fi
                    done
                done
            }

# --- Main function

gospec () {
    cmd_go_test="go test -count=1 -v -json ./..."
    cmd_jq="jq -c --slurp ."

    output=$($cmd_go_test | $cmd_jq)
    output_tests=$(get_tests "$output")
    fail_count=$(count_action "$output" "fail")

    initialize_colors

    if [ $fail_count -gt 0 ]; then
        println
        colorize "Failing tests:" "$RED"
        test_list_by_pkg "$output_tests" "fail" "yes"
    fi

    println
    test_summary "$output_tests"
}

gospec
