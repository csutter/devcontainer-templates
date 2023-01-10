#!/usr/bin/env bash

# Set up environment for tests to run (must be run before anything else)
# Arguments:
#   - name of the current template being tested (e.g. `ruby`)
#   - image tag (will replace `${templateOption:imageVariant}`, e.g. `3.2.0`)
setup() {
  # Set up variables
  TEMPLATE=$1
  IMAGE_TAG=$2

  ID_LABEL="devcontainer-test=$TEMPLATE"

  SRC_DIR=$(dirname "$0")
  TEST_ROOT=/tmp/devcontainer-templates
  TEST_DIR=$TEST_ROOT/$TEMPLATE

  PASSED_TESTS=0
  FAILED_TESTS=0

  # Set up and empty test directory, ensuring test root directory exists
  mkdir -p $TEST_ROOT || true
  rm -rf "$TEST_DIR"

  # Copy devcontainer sources and test scripts/data to temporary directory
  cp -R "$SRC_DIR"/../../src/"$TEMPLATE" $TEST_ROOT/
  cp -R "$SRC_DIR"/../../test/"$TEMPLATE" $TEST_ROOT/

  # Validate template is valid JSON before doing anything else and getting into a weird place
  jq . "$TEST_DIR"/devcontainer-template.json > /dev/null

  # Substitute image tag from template options
  #   A "supporting tool" (e.g. VS Code) would normally do this as part of the interactive
  #   installation process
  #   TODO: Revisit this in the future to see if there is a neater way to do this, for example with
  #     future `devcontainer` CLI functionality
  sed -i -e "s/\${templateOption:imageVariant}/${IMAGE_TAG}/g" "$TEST_DIR"/.devcontainer/Dockerfile

  # Start devcontainer
  devcontainer up --workspace-folder "$TEST_DIR" --id-label "$ID_LABEL"
}

# Clean up after ourselves on success or failure
cleanup() {
  # Get rid of container if running
  CONTAINER=$(docker container ls -f "label=${ID_LABEL}" -q)
  [[ -z "$CONTAINER" ]] || docker rm -f "$CONTAINER" > /dev/null

  # Remove test directory
  rm -rf "$TEST_DIR"
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

  local result
  # `devcontainer exec` gives its _own_ output on stdout, with the actual output of the command run
  # on stderr. In theory, we could validate that the exec output includes `{"outcome": "success"}`,
  # but if we get the expected output from the exec'd command back that's good enough anyway.
  # Also as this script is set to abort on error, make sure we continue running even if the exit
  # code of the in-container execution is non-zero.
  #
  # We _want_ $cmd to be split here as it could include arguments:
  # shellcheck disable=SC2086
  result=$(devcontainer exec --workspace-folder "$TEST_DIR" --id-label "$ID_LABEL" $cmd 2>&1 1> /dev/null || true)

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

# Print results, clean up, and return an appropriate exit code when the script finishes
end_tests() {
  # Clean up and print test output
  cleanup
  echo "Passed test(s): $PASSED_TESTS, failed test(s): $FAILED_TESTS"

  # Succeed if there are no failed tests, but also make sure that at least one test has passed
  # (otherwise something else might have gone wrong)
  [ $FAILED_TESTS -eq 0 ] && [ $PASSED_TESTS -gt 0 ]
}
trap "end_tests" EXIT
