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

# Download Swift Toolchain.
if [[ $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  echo "Downloading Swift snapshot version: ${SWIFT_VERSION} ..."
  DL_SWIFT_BASENAME_SUFFIX="swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}"
  DL_SWIFT_URL="https://download.swift.org/development/xcode/${DL_SWIFT_BASENAME_SUFFIX}/${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg"
else
  echo "Downloading Swift release version: ${SWIFT_VERSION} ..."
  DL_SWIFT_BASENAME_SUFFIX="swift-${SWIFT_VERSION}-RELEASE"
  DL_SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/xcode/${DL_SWIFT_BASENAME_SUFFIX}/${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg"
fi
curl -sL "${DL_SWIFT_URL}" -o "/tmp/${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg"

# Install Swift Toolchain.
echo "Installing ${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg ..."
xattr -dr com.apple.quarantine "/tmp/${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg"
sudo installer -pkg "/tmp/${DL_SWIFT_BASENAME_SUFFIX}-osx.pkg" -target /
export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/${DL_SWIFT_BASENAME_SUFFIX}.xctoolchain/Info.plist")
echo TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/${DL_SWIFT_BASENAME_SUFFIX}.xctoolchain/Info.plist") >> $GITHUB_ENV

# Output Swift version.
swift --version
