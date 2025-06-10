#!/bin/sh

set -euo pipefail

MODULE_NAME="Puppy"
SCRIPT_TYPE=${SCRIPT_TYPE:-build}

xcodebuild -showsdks
xcrun simctl list devices

dests[0]="platform=macOS"
dests[1]="platform=macOS,variant=Mac Catalyst"
dests[2]="platform=iOS Simulator,OS=latest,name=iPhone 16 Pro"
dests[3]="platform=tvOS Simulator,OS=latest,name=Apple TV 4K (3rd generation)"
dests[4]="platform=watchOS Simulator,OS=latest,name=Apple Watch Series 10 (46mm)"
dests[5]="platform=visionOS Simulator,OS=latest,name=Apple Vision Pro"

for dest in "${dests[@]}"
do
  if  [ "${SCRIPT_TYPE}" = "test" ]; then
    xcodebuild clean build-for-testing test-without-building -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Debug -destination "${dest}" ENABLE_TESTABILITY=YES | xcpretty -c
  else
    xcodebuild clean build -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Release -destination "${dest}" | xcpretty -c
  fi
done
