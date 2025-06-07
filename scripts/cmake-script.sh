#!/usr/bin/env bash

set -eu

DISTRIBUTION=${DISTRIBUTION:-'noble'}
CMAKE_VERSION=${CMAKE_VERSION:-'4.0.2'}
NINJA_VERSION=${NINJA_VERSION:-'1.12.1'}

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
  if ! type ninja > /dev/null 2>&1; then packages+=('ninja-build'); fi
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
    noble|jammy)
      if [ ${#packages[@]} -ne 0 ]; then
        apt-get -qq update && apt-get -qq install -y ${packages[@]}
      fi
      ;;
    amazonlinux2)
      if [ ${#packages[@]} -ne 0 ]; then
        yum -q -y update && yum -q -y install ${packages[@]}
      fi
      ;;
    *)
      echo "Unexpected distribution name: ${DISTRIBUTION}"
      exit 1
      ;;
  esac

  # Install CMake.
  if [ $(uname -m) = 'aarch64' ]; then DL_FILE_SUFFIX="-aarch64"; else DL_FILE_SUFFIX="-x86_64"; fi
  echo "Downloading CMake ${CMAKE_VERSION} for $(uname -m) ..."
  curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}.tar.gz" -o "/tmp/cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}.tar.gz"
  echo "Installing cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}.tar.gz ..."
  tar xfz "/tmp/cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}.tar.gz" -C /opt
  export PATH="/opt/cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}/bin:${PATH}"
  if [ -v GITHUB_ACTIONS ]; then
    echo "/opt/cmake-${CMAKE_VERSION}-linux${DL_FILE_SUFFIX}/bin:${PATH}" >> $GITHUB_PATH
  fi

  # Install Ninja.
  if [ $(uname -m) = 'aarch64' ]; then DL_FILE_SUFFIX="-aarch64"; else DL_FILE_SUFFIX=””; fi
  echo "Downloading Ninja ${NINJA_VERSION} for $(uname -m) ..."
  curl -sL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux${DL_FILE_SUFFIX}.zip" -o "/tmp/ninja-linux${DL_FILE_SUFFIX}.zip"
  echo "Installing ninja-linux${DL_FILE_SUFFIX}.zip ..."
  unzip "/tmp/ninja-linux${DL_FILE_SUFFIX}.zip" -d /usr/bin
  chmod u+x /usr/bin/ninja

fi

# Assume OS is Windows.
if [ $(uname) != 'Darwin' ] && [ $(uname) != 'Linux' ]; then
  if ! type cmake > /dev/null 2>&1; then
    choco install cmake --installargs '"ADD_CMAKE_TO_PATH=System"' --yes --no-progress
  fi
  if ! type ninja > /dev/null 2>&1; then
    choco install ninja --yes --no-progress
  fi
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
    export SWIFTFLAGS=$(echo "-sdk $SDKROOT" | sed 's/\\/\//g')
    echo "SWIFTFLAGS is ${SWIFTFLAGS}"
    cmake -B ./build -D CMAKE_C_COMPILER=clang -D CMAKE_BUILD_TYPE=Release -D CMAKE_Swift_FLAGS="${SWIFTFLAGS}" -G Ninja -S .
    ninja -C ./build -v   # or `cmake --build ./build -v`
    ;;
esac
