#!/bin/sh

set -eu

SCRIPT_TYPE=${SCRIPT_TYPE:-report}

if  [ "${SCRIPT_TYPE}" = "export" ]; then
  echo "Deleting coverage.lcov..."
  rm -f coverage.lcov
fi

swift test --enable-test-discovery --enable-code-coverage

BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find ${BIN_PATH} -name '*.xctest')"

COV_BIN=$XCTEST_PATH
LLVM_COV='llvm-cov'

case $(uname) in
  Darwin)
    f="$(basename $XCTEST_PATH .xctest)"
    COV_BIN="${COV_BIN}/Contents/MacOS/$f"
    LLVM_COV="xcrun llvm-cov"
    ;;
  Linux)
    ;;
  *)
    echo "unexpected OS"
    exit 1
    ;;
esac

if  [ "${SCRIPT_TYPE}" = "export" ]; then
  $LLVM_COV export -format="lcov" "${COV_BIN}" \
      -instr-profile=.build/debug/codecov/default.profdata \
      -ignore-filename-regex=".build|Tests" \
      > coverage.lcov
else
  $LLVM_COV report "${COV_BIN}" \
      -instr-profile=.build/debug/codecov/default.profdata \
      -ignore-filename-regex=".build|Tests" \
      -use-color
fi
