#!/bin/sh

set -euo pipefail

MODULE_NAME="Puppy"
SCRIPT_TYPE=${SCRIPT_TYPE:-build}

dests[0]="platform=macOS"
dests[1]="platform=macOS,variant=Mac Catalyst"
dests[2]="platform=iOS Simulator,name=iPhone 8"
dests[3]="platform=tvOS Simulator,name=Apple TV"
dests[4]="platform=watchOS Simulator,name=Apple Watch Series 5 (40mm)"

for dest in "${dests[@]}"
do
  if  [ "${SCRIPT_TYPE}" = "test" ]; then
    xcodebuild clean build-for-testing test-without-building -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Debug -destination "${dest}" ENABLE_TESTABILITY=YES | xcpretty -c
  else
    xcodebuild clean build -workspace "${MODULE_NAME}".xcworkspace -scheme "${MODULE_NAME}" -configuration Release -destination "${dest}" | xcpretty -c
  fi
done
