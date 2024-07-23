#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../harness.sh"

setup "barebones-nodejs" "20.15.1"

run_test "Node version is correct" "node -v" "$IMAGE_TAG"
run_test "NPM is present" "npm --help" "npm <command>"
run_test "Sample script runs" "node sample.js" "Hello world"
run_test "Container defaults to non-root user" "whoami" "node"
run_test "Non-root user is able to sudo" "sudo whoami" "root"
