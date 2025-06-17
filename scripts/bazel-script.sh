#!/usr/bin/env bash

set -eu

MODULE_NAME=${MODULE_NAME:-'puppy'}

SCRIPT_TYPE=${SCRIPT_TYPE:-'build'}
DISTRIBUTION=${DISTRIBUTION:-'noble'}
BAZELISK_VERSION=${BAZELISK_VERSION:-'1.26.0'}

# macOS
if [ $(uname) = 'Darwin' ]; then
  if ! type bazelisk > /dev/null 2>&1; then
    brew update && brew install bazelisk
  fi
fi

# Linux
if [ $(uname) = 'Linux' ] && [ ! -e '/.dockerenv' ]; then
  if ! type bazelisk > /dev/null 2>&1; then
    sudo apt-get -qq update && sudo apt-get -qq install -y ${packages[@]}
  fi
fi

# Linux Container
if [ $(uname) = 'Linux' ] && [ -e '/.dockerenv' ]; then
  declare -a packages=()
  if ! type curl > /dev/null 2>&1; then packages+=('curl'); fi
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
      echo "Unexpected distribution: ${DISTRIBUTION}"
      exit 1
      ;;
  esac

  # Install Bazelisk.
  if [ $(uname -m) = 'aarch64' ]; then DL_FILE_SUFFIX="-arm64"; else DL_FILE_SUFFIX="-amd64"; fi
  echo "Download Bazelisk ${BAZELISK_VERSION} for $(uname -m) ..."
  curl -sL "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux${DL_FILE_SUFFIX}" -o /usr/bin/bazelisk
  chmod u+x /usr/bin/bazelisk

fi

# Show Bazelisk version.
bazelisk version

# Build or test with Bazelisk.
bazelisk clean --expunge
if [ "${SCRIPT_TYPE}" = 'test' ]; then
  CC=clang bazelisk test //:"${MODULE_NAME}"_tests --verbose_failures --test_verbose_timeout_warnings
else
  CC=clang bazelisk build //:"${MODULE_NAME}" --verbose_failures
fi
