#!/usr/bin/env bash

set -eu

# Intall packates.
declare -a packages=()

case $(uname) in
  Darwin)
    if ! type cmake > /dev/null 2>&1; then packages+=('cmake'); fi
    if ! type ninja > /dev/null 2>&1; then packages+=('ninja'); fi
    if [ ${#packages[@]} -ne 0 ]; then
      brew update && brew install ${packages[@]}
    fi
    ;;
  Linux)
    if ! type cmake > /dev/null 2>&1; then packages+=('cmake'); fi
    if ! type ninja > /dev/null 2>&1; then packages+=('ninja-build'); fi
    if [ ${#packages[@]} -ne 0 ]; then
      if [ -e '/.dockerenv' ]; then
        apt-get -q update && apt-get -q install -y ${packages[@]}
      else
        sudo apt-get -q update && sudo apt-get -q install -y ${packages[@]}
      fi
    fi
    ;;
  *) # Assume OS is Windows.
    ;;
esac

cmake --version
ninja --version

# Build with CMake and Ninja.
rm -rf build

case $(uname) in
  Darwin|Linux)
    cmake -B ./build -D CMAKE_C_COMPILER=clang -D CMAKE_BUILD_TYPE=RelWithDebInfo -G Ninja -S .
    ninja -C ./build -v   # or `cmake --build ./build -v`
    ;;
  *) # Assume OS is Windows.
    export SWIFTFLAGS='-sdk C:/Library/Developer/Platforms/Windows.platform/Developer/SDKs/Windows.sdk'
    cmake -B ./build -D CMAKE_C_COMPILER=clang -D CMAKE_BUILD_TYPE=Release -D CMAKE_Swift_FLAGS="${SWIFTFLAGS}" -G Ninja -S .
    ninja -C ./build -v   # or `cmake --build ./build -v`
    ;;
esac
