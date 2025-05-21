#!/usr/bin/env bash

set -eu

SWIFT_VERSION=${SWIFT_VERSION:-'6.0.3'}   # e.g.'5.10' '6.0.3' '2025-01-10-a'

if ! ${GITHUB_ACTIONS}; then
  exit 1
fi

# Remove the Swift minor version if it is 0.
if [[ ! $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  split_version=(${SWIFT_VERSION//./ })
  if [ ${#split_version[@]} -eq 3 ] && [ ${split_version[2]} -eq 0 ]; then
    SWIFT_VERSION=${split_version[0]}.${split_version[1]}
  fi
fi

# Check the Swift version whether it is already installed or not.
if `type swift > /dev/null 2>&1` && [[ $(swift --version | head -n 1) =~ " Swift version $SWIFT_VERSION " ]]; then
  echo "Swift ${SWIFT_VERSION} is already installed."
  swift --version
  exit 0
fi

# Get distribution info.
DISTRO_NAME=$(cat /etc/os-release | grep '^NAME=' | awk -F['='] '{print $2}' | sed -e 's/"//g')
DISTRO_VERSION_ID=$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F['='] '{print $2}' | sed -e 's/"//g')

if [ "${DISTRO_NAME}" != 'Ubuntu' ]; then
  echo "Unsupported distribution name: ${DISTRO_NAME}"
  exit 1
fi

if [ "${DISTRO_VERSION_ID}" != '24.04' ] && [ "${DISTRO_VERSION_ID}" != '22.04' ] && [ "${DISTRO_VERSION_ID}" != '20.04' ]; then
  echo "Unsupported distribution version: ${DISTRO_VERSION_ID}"
  exit 1
fi

DISTRO_NAME_LOWERCASE=$(echo "${DISTRO_NAME}" | tr "[:upper:]" "[:lower:]")
DISTRO_VERSION_ID_WO_DOT=$(echo "${DISTRO_VERSION_ID}" | sed -e 's/\.//g')

# Download Swift Toolchain.
if [[ $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  echo "Downloading Swift snapshot version: ${SWIFT_VERSION} ..."
  DL_SWIFT_BASENAME="swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}"
  DL_SWIFT_URL="https://download.swift.org/development/${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID_WO_DOT}/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}/${DL_SWIFT_BASENAME}.tar.gz"
else
  echo "Downloading Swift release version: ${SWIFT_VERSION} ..."
  DL_SWIFT_BASENAME="swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}"
  DL_SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID_WO_DOT}/swift-${SWIFT_VERSION}-RELEASE/${DL_SWIFT_BASENAME}.tar.gz"
fi
curl -sL "${DL_SWIFT_URL}" -o "/tmp/${DL_SWIFT_BASENAME}.tar.gz"

# Install Swift Toolchain.
echo "Installing ${DL_SWIFT_BASENAME}.tar.gz ..."
tar xfz "/tmp/${DL_SWIFT_BASENAME}.tar.gz" -C /opt
export PATH="/opt/${DL_SWIFT_BASENAME}/usr/bin:${PATH}"
echo "/opt/${DL_SWIFT_BASENAME}/usr/bin" >> $GITHUB_PATH

# Output Swift version.
swift --version
