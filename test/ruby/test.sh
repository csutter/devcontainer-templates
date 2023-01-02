#!/bin/bash
set -euo pipefail

TEMPLATE=ruby
ID_LABEL="devcontainer-test=$TEMPLATE"

SRC_DIR=$(dirname "$0")
TEST_ROOT=/tmp/lightweight-devcontainer-templates
TEST_DIR=$TEST_ROOT/$TEMPLATE

PASSED_TESTS=0
FAILED_TESTS=0

# Clean up after ourselves on success or failure
cleanup() {
  # Get rid of container if running
  CONTAINER=$(docker container ls -f "label=${ID_LABEL}" -q)
  [[ -z "$CONTAINER" ]] || docker rm -f "$CONTAINER" > /dev/null

  # Remove test directory
  rm -rf $TEST_DIR
}

cleanup_from_error_or_interrupt() {
  cleanup
  exit 1
}
trap "cleanup_from_error_or_interrupt" ERR SIGINT

# Run a command in the container using `devcontainer exec` and check its output contains a string
run_test() {
  local description=$1
  local cmd=$2
  local expected_result=$3

  # `devcontainer exec` gives its _own_ output on stdout, with the actual output of the command run
  # on stderr. In theory, we could validate that the exec output includes `{"outcome": "success"}`,
  # but if we get the expected output from the exec'd command back that's good enough anyway.
  local result
  result=$(devcontainer exec --workspace-folder "$TEST_DIR" --id-label "$ID_LABEL" "$cmd" 2>&1 1> /dev/null)

  case "$result" in
    *$expected_result*)
      echo "[PASS] $description"
      PASSED_TESTS=$((PASSED_TESTS + 1))
      ;;
    *)
      echo "[FAIL] $description"
      echo "  Expected output of '$cmd' to contain '$expected_result', but got '$result'"
      FAILED_TESTS=$((FAILED_TESTS + 1))
      ;;
  esac
}

# Specific image tag to request (and test for later)
IMAGE_TAG=3.2.0

# Set up and empty test directory, ensuring test root directory exists
mkdir -p $TEST_ROOT || true
rm -rf $TEST_DIR

# Copy devcontainer sources and test scripts/data to temporary directory
cp -R "$SRC_DIR"/../../src/$TEMPLATE $TEST_ROOT/
cp -R "$SRC_DIR"/../../test/$TEMPLATE $TEST_ROOT/

# Validate template is valid JSON before doing anything else and getting into a weird place
jq . $TEST_DIR/devcontainer-template.json > /dev/null

# Substitute Ruby version from template options
#   A "supporting tool" (e.g. VS Code) would normally do this as part of the interactive
#   installation process
#   TODO: Revisit this in the future to see if there is a neater way to do this, for example with
#     future `devcontainer` CLI functionality
sed -i -e "s/\${templateOption:imageVariant}/${IMAGE_TAG}/g" $TEST_DIR/.devcontainer/Dockerfile

# Start devcontainer
devcontainer up --workspace-folder $TEST_DIR --id-label $ID_LABEL

# Run tests
run_test "Ruby version is correct" "ruby -v" $IMAGE_TAG
run_test "Sample script runs" "ruby sample.rb" "Hello world"
run_test "Container defaults to non-root user" "whoami" "devcontainer"
run_test "Non-root user is able to sudo" "sudo whoami" "root"

# Clean up and print test output
cleanup
echo "Passed test(s): $PASSED_TESTS, failed test(s): $FAILED_TESTS"

# Succeed if there are no failed tests, but also make sure that at least one test has passed
# (otherwise something else might have gone wrong)
[ $FAILED_TESTS -eq 0 ] && [ $PASSED_TESTS -gt 0 ]
