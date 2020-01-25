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

    local color="green"
    if [ $fail_count -gt 0 ]; then
        color="red"
    fi

    result+=$(colorize "$pass_count PASS, $fail_count FAIL, $skip_count SKIP" "$color")
    echo $result
}

gospec () {
    cmd_go_test="go test -count=1 -v -json ./..."
    cmd_jq="jq -c --slurp ."

    output=$($cmd_go_test | $cmd_jq)

    output_tests=$(get_tests "$output")

    echo $(test_summary "$output_tests")

    fail_count=$(count_action "$output" "fail")

    if [ $fail_count -gt 0 ]; then
        println
        println "Failing tests:"

        get_by_action "$output_tests" "fail" | \
            jq -c 'group_by(.Package) | .[]' | \
            while read failed_package; do
                package_name=$(echo "$failed_package" | jq -r '[.[].Package] | unique | .[0]')
                println
                println "$package_name"
                echo "$failed_package" | \
                    jq -r 'sort_by(.Test) | reverse | .[].Test' | \
                    while read test_name; do
                        println "\t$test_name";
                        local action="output";
                        get_by_test_and_action "$output_tests" "$test_name" "output" | \
                            jq -r '.[].Output | select(test("(FAIL|RUN)") | not) | sub("\\n"; "")'
                    done
                done
    fi
}

gospec
