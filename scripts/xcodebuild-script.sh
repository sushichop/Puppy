#!/bin/sh

set -euo pipefail

MODULE_NAME="Puppy"
SCRIPT_TYPE=${SCRIPT_TYPE:-build}
PLATFORMS=(macOS macCatalyst iOS watchOS tvOS visionOS)

echo "===== Xcode SDKs ====="
xcodebuild -showsdks

echo
echo
echo "===== Simulator Devices (simctl) ====="
xcrun simctl list devices

echo
echo
echo "===== Simulator Devices (xctrace) ====="
xcrun xctrace list devices

echo
echo
echo "===== Selected Destinations ====="

DEVICES="$(xcrun xctrace list devices)"

for PLATFORM in "${PLATFORMS[@]}"; do
  PREFIX=""
  SIMULATOR_PLATFORM=""

  case "${PLATFORM}" in
    macOS)
      DESTINATION="platform=macOS,arch=arm64"
      ;;

    macCatalyst)
      DESTINATION="platform=macOS,arch=arm64,variant=Mac Catalyst"
      ;;

    iOS)
      PREFIX="iPhone"
      SIMULATOR_PLATFORM="iOS Simulator,arch=arm64"
      ;;

    watchOS)
      PREFIX="Apple Watch"
      SIMULATOR_PLATFORM="watchOS Simulator,arch=arm64"
      ;;

    tvOS)
      PREFIX="Apple TV"
      SIMULATOR_PLATFORM="tvOS Simulator,arch=arm64"
      ;;

    visionOS)
      PREFIX="Apple Vision"
      SIMULATOR_PLATFORM="visionOS Simulator,arch=arm64"
      ;;
  esac

  if [[ -n "${PREFIX}" ]]; then
    VERSION="$(printf '%s\n' "${DEVICES}" | grep "^${PREFIX}.*Simulator (" | sed -E 's/.* Simulator \(([0-9.]+)\) .*/\1/' | sort -V | tail -n 1)"

    NAME="$(printf '%s\n' "${DEVICES}" | grep "^${PREFIX}.* Simulator (${VERSION}) " | head -n 1 | sed -E 's/ Simulator \([0-9.]+\) \([^)]*\)$//')"

    [[ -n "${NAME}" ]] || { echo "No Simulator found for ${PLATFORM}"; exit 1; }

    DESTINATION="platform=${SIMULATOR_PLATFORM},name=${NAME},OS=${VERSION}"
  fi

  echo
  echo "==> ${SCRIPT_TYPE}: ${PLATFORM}"
  echo "    Destination: ${DESTINATION}"

  if [[ "${SCRIPT_TYPE}" == "test" ]]; then
    xcodebuild clean build-for-testing test-without-building -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Debug -destination "${DESTINATION}" ENABLE_TESTABILITY=YES | xcpretty -c
  else
    xcodebuild clean build -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Release -destination "${DESTINATION}" | xcpretty -c
  fi
done
