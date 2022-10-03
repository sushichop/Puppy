#!/usr/bin/env bash

set -eu

MODULE_NAME=${MODULE_NAME:-'Puppy'}

SCRIPT_TYPE=${SCRIPT_TYPE:-'build'}
DISTRIBUTION=${DISTRIBUTION:-'focal'}
BAZELISK_VERSION=${BAZELISK_VERSION:-'1.14.0'}

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

  # Install Bazelisk.
  echo "Download Bazelisk ${BAZELISK_VERSION} ..."
  curl -sL "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64" -o /usr/bin/bazelisk
  chmod u+x /usr/bin/bazelisk
fi

# Show Bazelisk version.
bazelisk version

# Build or test with Bazelisk.
bazelisk clean --expunge
if [ "${SCRIPT_TYPE}" = 'test' ]; then
  CC=clang bazelisk test //:"${MODULE_NAME}"TestsRunner --verbose_failures --test_verbose_timeout_warnings --test_output=errors
else
  CC=clang bazelisk build //:"${MODULE_NAME}" --verbose_failures
fi
