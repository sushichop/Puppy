#!/bin/sh

set -eu

MODULE_NAME="Puppy"
SCRIPT_TYPE=${SCRIPT_TYPE:-build}
BAZELISK_VERSION="1.11.0"

case $(uname) in
  Darwin)
    if ! type bazelisk > /dev/null 2>&1; then
      brew update && brew install bazelisk
    fi
    ;;
  Linux)
    apt-get update && apt-get install -y curl
    curl -L -o /usr/bin/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v"${BAZELISK_VERSION}"/bazelisk-linux-amd64
    chmod u+x /usr/bin/bazelisk
    ;;
  *)
    echo "unexpected OS"
    exit 1
    ;;
esac

bazelisk version
bazelisk clean --expunge

if [ "${SCRIPT_TYPE}" = "test" ]; then
  CC=clang bazelisk test //:"${MODULE_NAME}"TestsRunner --verbose_failures --test_verbose_timeout_warnings --test_output=errors
else
  CC=clang bazelisk build //:"${MODULE_NAME}" --verbose_failures
fi
