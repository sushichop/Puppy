#!/bin/sh

set -eu

SCRIPT_TYPE=${SCRIPT_TYPE:-}

case $(uname) in
  Darwin)
    if ! type cmake > /dev/null 2>&1; then
      brew update && brew install cmake
    fi
    if ! type ninja > /dev/null 2>&1; then
      brew update && brew install ninja
    fi
    ;;
  Linux)
    apt-get update && apt-get install -y cmake ninja-build
    ;;
  *)
    echo "unexpected OS"
    exit 1
    ;;
esac

cmake --version
ninja --version

rm -rf build
cmake -B ./build -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=Debug -G Ninja -S .

if [ "${SCRIPT_TYPE}" = "ninja" ]; then
  ninja -C ./build -v
else
  cmake --build ./build -v
fi
