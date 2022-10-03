#!/usr/bin/env bash

set -eu

DISTRIBUTION=${DISTRIBUTION:-'focal'}
CMAKE_VERSION=${CMAKE_VERSION:-'3.24.2'}
NINJA_VERSION=${NINJA_VERSION:-'1.11.1'}

# macOS
if [ $(uname) = 'Darwin' ]; then
  declare -a packages=()
  if ! type cmake > /dev/null 2>&1; then packages+=('cmake'); fi
  if ! type ninja > /dev/null 2>&1; then packages+=('ninja'); fi
  if [ ${#packages[@]} -ne 0 ]; then
    brew update && brew install ${packages[@]}
  fi
fi

# Linux
if [ $(uname) = 'Linux' ] && [ ! -e '/.dockerenv' ]; then
  declare -a packages=()
  if ! type cmake > /dev/null 2>&1; then packages+=('cmake'); fi
  if ! type ninja > /dev/null 2>&1; then packages+=('ninja'); fi
  if [ ${#packages[@]} -ne 0 ]; then
    sudo apt-get -qq update && sudo apt-get -qq install -y ${packages[@]}
  fi
fi

# Linux Container
if [ $(uname) = 'Linux' ] && [ -e '/.dockerenv' ]; then
  declare -a packages=()
  if ! type curl > /dev/null 2>&1; then packages+=('curl'); fi
  if ! type unzip > /dev/null 2>&1; then packages+=('unzip'); fi

  case ${DISTRIBUTION} in
    focal|bionic)
      if [ ${#packages[@]} -ne 0 ]; then
        apt-get -qq update && apt-get -qq install -y ${packages[@]}
      fi
      ;;
    amazonlinux2|centos7)
      if [ ${#packages[@]} -ne 0 ]; then
        yum -q -y update && yum -q -y install ${packages[@]}
      fi
      ;;
    *)
      echo "unexpected distribution: ${DISTRIBUTION}"
      exit 1
      ;;
  esac

  # Install CMake.
  echo "Download CMake ${CMAKE_VERSION} ..."
  curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" -o "/tmp/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
  tar xfz "/tmp/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" -C /opt
  export PATH="/opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin:${PATH}"
  if [ -v GITHUB_ACTIONS ]; then
    echo "/opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin:${PATH}" >> $GITHUB_PATH
  fi
  # Install Ninja.
  echo "Download Ninja ${NINJA_VERSION} ..."
  curl -sL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip" -o "/tmp/ninja-linux.zip"
  unzip /tmp/ninja-linux.zip -d /usr/bin
  chmod u+x /usr/bin/ninja
fi

# Show versions.
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
