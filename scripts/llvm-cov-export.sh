#!/bin/sh

echo "Deleting coverage.lcov..."
rm -f coverage.lcov

BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find ${BIN_PATH} -name '*.xctest')"

COV_BIN=$XCTEST_PATH
LLVM_COV='llvm-cov'

case $OSTYPE in
  darwin*)
    f="$(basename $XCTEST_PATH .xctest)"
    COV_BIN="${COV_BIN}/Contents/MacOS/$f"
    LLVM_COV='xcrun llvm-cov'
    ;;
  *)
    ;;
esac

$LLVM_COV export -format="lcov" "${COV_BIN}" \
    -instr-profile=.build/debug/codecov/default.profdata \
    -ignore-filename-regex=".build|Tests" \
    > coverage.lcov
