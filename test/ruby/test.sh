#!/bin/bash
set -euo pipefail

set -x # TODO: Remove when no longer needed for debugging

TEMPLATE=ruby
ID_LABEL="devcontainer-test=$TEMPLATE"

SRC_DIR=$(dirname "$0")
TEST_ROOT=/tmp/lightweight-devcontainer-templates
TEST_DIR=$TEST_ROOT/$TEMPLATE

# Clean up after ourselves on success or failure
cleanup() {
  # Get rid of container if running
  CONTAINER=$(docker container ls -f "label=${ID_LABEL}" -q)
  [[ -z "$CONTAINER" ]] || docker rm -f $CONTAINER > /dev/null

  # Remove test directory
  rm -rf $TEST_DIR

  # Stop the script (in case cleanup is called from signal handler, not at the end of script)
  exit
}
trap "cleanup" ERR SIGINT

# Run a command in the devcontainer using `devcontainer exec` for its output
exec_with_output() {
  # `devcontainer exec` gives its _own_ output on stdout, with the actual output of the command run
  # on stderr. In theory, we could validate that the exec output includes `{"outcome": "success"}`,
  # but if we get the expected output from the exec'd command back that's good enough anyway.
  devcontainer exec --workspace-folder "$TEST_DIR" --id-label "$ID_LABEL" $1 > /dev/null
}

# Set up and empty test directory, ensuring test root directory exists
mkdir -p $TEST_ROOT || true
rm -rf $TEST_DIR

# Copy devcontainer sources and test scripts/data to temporary directory
cp -R $SRC_DIR/../../src/$TEMPLATE $TEST_ROOT/
cp -R $SRC_DIR/../../test/$TEMPLATE $TEST_ROOT/

# Validate template is valid JSON before doing anything else and getting into a weird place
jq . $TEST_DIR/devcontainer-template.json > /dev/null

# Substitute Ruby version from template options
#   A "supporting tool" (e.g. VS Code) would normally do this as part of the interactive
#   installation process
#   TODO: Revisit this in the future to see if there is a neater way to do this, for example with
#     future `devcontainer` CLI functionality
sed -i -e 's/${templateOption:imageVariant}/3.2.0/g' $TEST_DIR/.devcontainer/Dockerfile

# Start devcontainer
devcontainer up --workspace-folder $TEST_DIR --id-label $ID_LABEL

# Check Ruby version
# TEST_RUBY_VERSION=$(devcontainer exec --workspace-folder "$TEST_DIR" --id-label "$ID_LABEL" ruby -v)
exec_with_output "ruby -v"

# Check script runs
exec_with_output "ruby sample.rb"

# Clean up
cleanup
