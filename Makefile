.DEFAULT_GOAL := help
HELP_INDENT := 28

SWIFT_VERSION := 5.3.2

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_INDENT)s\033[0m %s\n", $$1, $$2}'

.PHONY: simctl-list-devices
simctl-list-devices: ## Run xcrun simctl list devices
	xcrun simctl list devices

.PHONY: simctl-delete-unavailable
simctl-delete-unavailable: ## Run xcrun simctl delete unavailable
	xcrun simctl delete unavailable

.PHONY: xctrace-list-devices
xctrace-list-devices: ## Run xcrun xctrace list devices
	xcrun xctrace list devices

.PHONY: xcode-build
xcode-build: ## Run build using Xcode
	set -o pipefail && xcodebuild clean build -workspace Puppy.xcworkspace -scheme Puppy -configuration Release -destination "platform=macOS" | xcpretty -c
	set -o pipefail && xcodebuild clean build -workspace Puppy.xcworkspace -scheme Puppy -configuration Release -destination "platform=macOS,variant=Mac Catalyst" | xcpretty -c
	set -o pipefail && xcodebuild clean build -workspace Puppy.xcworkspace -scheme Puppy -configuration Release -destination "platform=iOS Simulator,name=iPhone 8" | xcpretty -c
	set -o pipefail && xcodebuild clean build -workspace Puppy.xcworkspace -scheme Puppy -configuration Release -destination "platform=tvOS Simulator,name=Apple TV" | xcpretty -c
	set -o pipefail && xcodebuild clean build -workspace Puppy.xcworkspace -scheme Puppy -configuration Release -destination "platform=watchOS Simulator,name=Apple Watch Series 5 - 40mm" | xcpretty -c

.PHONY: xcode-test
xcode-test: ## Run tests using Xcode
	set -o pipefail && xcodebuild clean build-for-testing test-without-building -workspace Puppy.xcworkspace -scheme Puppy -configuration Debug -destination "platform=macOS" ENABLE_TESTABILITY=YES | xcpretty -c
	set -o pipefail && xcodebuild clean build-for-testing test-without-building -workspace Puppy.xcworkspace -scheme Puppy -configuration Debug -destination "platform=macOS,variant=Mac Catalyst" ENABLE_TESTABILITY=YES | xcpretty -c
	set -o pipefail && xcodebuild clean build-for-testing test-without-building -workspace Puppy.xcworkspace -scheme Puppy -configuration Debug -destination "platform=iOS Simulator,name=iPhone 8" ENABLE_TESTABILITY=YES | xcpretty -c
	set -o pipefail && xcodebuild clean build-for-testing test-without-building -workspace Puppy.xcworkspace -scheme Puppy -configuration Debug -destination "platform=tvOS Simulator,name=Apple TV" ENABLE_TESTABILITY=YES | xcpretty -c

.PHONY: swift-test
swift-test: ## Run tests using SwiftPM
	./scripts/llvm-cov-report.sh

.PHONY: swift-test-linux
swift-test-linux: ## Run tests using SwiftPM on linux with docker
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) bash -x ./scripts/llvm-cov-report.sh

.PHONY: export-codecov
export-codecov: ## Export code coverage
	./scripts/llvm-cov-export.sh
	#bash <(curl https://codecov.io/bash)

.PHONY: export-codecov-linux
export-codecov-linux: ## Export code coverage on Linux with Docker
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) ./scripts/llvm-cov-export.sh
	#bash <(curl https://codecov.io/bash)

.PHONY: swiftlint
swiftlint: ## Run SwiftLint
	swiftlint lint

.PHONY: swiftlint-autocorrect
swiftlint-autocorrect: ## Run SwiftLint with autocorrect format
	swiftlint autocorrect --format

.PHONY: pod-lib-lint
pod-lib-lint: ## Run pod lib lint
	pod lib lint

.PHONY: carthage-build
carthage-build: ## Run carthage build
	@echo "Deleting Carthage artifacts..."
	@rm -rf Carthage
	carthage build --no-skip-current

.PHONY: carthage-build-workaround
carthage-build-workaround: ## Run carthage build with workaround
	@echo "Deleting Carthage artifacts..."
	@rm -rf Carthage
	./scripts/carthage-workaround.sh build --no-skip-current

.PHONY: linux
linux: ## Run and login docker container
	docker run --rm -it --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION)
