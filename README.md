# gospec

> Bash function that prettifies the output of `go test`

[![asciicast](https://asciinema.org/a/301631.svg)](https://asciinema.org/a/301631)

## Usage

```
$ gospec --help
gospec

gospec prettifies the output of `go test`

Usage:
    gospec [options] [package] [test-regex]

Available options:
    [ --no-color  | -C ] => do not use colors when printing the summarized output
    [ --no-output | -O ] => do not print output for failing tests
    [ --summary   | -S ] => print a list of passing and failing tests
    [ --passthru  | -P ] => Run the Go test command, don't change anything in the output

Examples:
    # Run complete test suite and print failing test output + list of failing tests
    gospec

    # Same as above: Don't use colors in the output
    gospec -C

    # Run complete test suite and print only the list of failing tests
    gospec -O

    # Run complete test suite and the list of passing and failing tests
    gospec -O -S

    # Run tests matching Percent in the utils package
    gospec ./utils Percent

    # Run all tests that match the given regex
    gospec "/Base"

    # Pass through to the underlying go test command: Don't mangle `go test`'s
    # output
    gospec pt

    # Pass through to the underlying go test command: Run tests in this package
    # that match the given regex
    gospec pt ./package regex

Webpage:
    https://github.com/icyflame/gospec
```

## Installation

**Note:** `gospec` requires [`jq`][1] as a pre-requisite.

`gospec` is a bash function. You can use it by placing the file in your path. I
recommend placing it in `$HOME/bin` and adding `$HOME/bin` to your path. You can
place it in any folder that is listed in your `$PATH` variable.

```sh
# Download the gospec bash function into a file in this directory
curl "https://raw.githubusercontent.com/icyflame/gospec/master/gospec" > "$HOME/bin/gospec"

# Restart your termianl or source your bashrc/zshrc and check that gospec can
# now be called
gospec --help
```

## Why?

`go test` is a great tool. But it's output is hugely lacking: the default output
is a wall of white text; there's no colors, failed tests aren't even highlighted
or summarized and printed at the end.

When you compare it to `rspec`'s default output, `go test` is blown out of the
water. Rspec's output in the any format is concise, colored appropriately and
prints the list of failing tests at the end.

I have two requirements from any testing tool:

- **Run a subset of all tests quickly:** I use when I am writing a new test or
  editing code that will affect an existing test.
- **Ensure that the test suite is passing before `git push`:** I use this while
  I am making changes that were requested in a review.

Gospec is opinionated. It doesn't print passing tests unless you use the
`--summary` option. It prints the output of failing tests by default. The bash
function is fairly small and simple, so my assumption is that anyone who wants a
different set of defaults will simply edit the bash function.

## License

Code inside this repo is licensed under the MIT License.

Copyright (c) 2020 [Siddharth Kannan](https://icyflame.github.io)

[1]: https://stedolan.github.io/jq/manual/
