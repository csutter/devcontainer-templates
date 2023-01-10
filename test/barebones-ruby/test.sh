#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../harness.sh"

setup "barebones-ruby" "3.2.0"

run_test "Ruby version is correct" "ruby -v" $IMAGE_TAG
run_test "Sample script runs" "ruby sample.rb" "Hello world"
run_test "Container defaults to non-root user" "whoami" "devcontainer"
run_test "Non-root user is able to sudo" "sudo whoami" "root"
