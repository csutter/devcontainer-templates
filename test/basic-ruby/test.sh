#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../harness.sh"

setup "basic-ruby" "3.3.4"

run_test "Ruby version is correct" "ruby -v" "$IMAGE_TAG"
run_test "Container defaults to non-root user" "whoami" "devcontainer"
run_test "Non-root user is able to sudo" "sudo whoami" "root"

run_test "The bundle is installed after creation" "bundle check" \
  "The Gemfile's dependencies are satisfied"
run_test "The template code satisfies Rubocop" "rubocop" "no offenses detected"
run_test "The example test runs" "rake test" "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"
