#!/bin/sh

set -euo pipefail

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

CURRENT_XCODE_VERSION="$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2 | cut -d'.' -f1)00"   # e.g. 1400
CURRENT_XCODE_BUILD=$(xcodebuild -version | grep "Build version" | cut -d' ' -f3)                 # e.g. 14A400

echo "EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_${CURRENT_XCODE_VERSION}__BUILD_${CURRENT_XCODE_BUILD} = arm64 arm64e armv7 armv7s armv6 armv8" >> $xcconfig

echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_'${CURRENT_XCODE_VERSION}' = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_$(XCODE_VERSION_MAJOR)__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"
carthage "$@"
