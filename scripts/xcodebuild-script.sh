#!/bin/sh

set -euo pipefail

MODULE_NAME="Puppy"
SCRIPT_TYPE=${SCRIPT_TYPE:-build}

xcodebuild -showsdks
xcrun simctl list devices

dests[0]="platform=macOS,arch=arm64"
dests[1]="platform=macOS,arch=arm64,variant=Mac Catalyst"
dests[2]="platform=iOS Simulator,arch=arm64,OS=latest,name=iPhone 17 Pro"
dests[3]="platform=tvOS Simulator,arch=arm64,OS=latest,name=Apple TV 4K (3rd generation)"
dests[4]="platform=watchOS Simulator,arch=arm64,OS=latest,name=Apple Watch Series 11 (46mm)"
dests[5]="platform=visionOS Simulator,arch=arm64,OS=latest,name=Apple Vision Pro"

for dest in "${dests[@]}"
do
  if  [ "${SCRIPT_TYPE}" = "test" ]; then
    xcodebuild clean build-for-testing test-without-building -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Debug -destination "${dest}" ENABLE_TESTABILITY=YES | xcpretty -c
  else
    xcodebuild clean build -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Release -destination "${dest}" | xcpretty -c
  fi
done
