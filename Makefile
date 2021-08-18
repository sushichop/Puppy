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
	./scripts/xcodebuild-script.sh

.PHONY: xcode-test
xcode-test: ## Run tests using Xcode
	SCRIPT_TYPE=test ./scripts/xcodebuild-script.sh

.PHONY: swift-test
swift-test: ## Run tests using SwiftPM
	./scripts/llvm-cov-script.sh

.PHONY: swift-test-linux
swift-test-linux: ## Run tests using SwiftPM on linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) ./scripts/llvm-cov-script.sh

.PHONY: export-codecov
export-codecov: ## Export code coverage
	SCRIPT_TYPE=export ./scripts/llvm-cov-script.sh
	#bash <(curl https://codecov.io/bash)

.PHONY: export-codecov-linux
export-codecov-linux: ## Export code coverage on linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) /bin/sh -c "SCRIPT_TYPE=export ./scripts/llvm-cov-script.sh"
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
	@echo "Deleting Carthage artifacts..." && rm -rf Carthage
	carthage build --no-skip-current

.PHONY: carthage-build-workaround
carthage-build-workaround: ## Run carthage build with workaround
	@echo "Deleting Carthage artifacts..." && rm -rf Carthage
	./scripts/carthage-workaround.sh build --no-skip-current

.PHONY: carthage-build-xcframeworks
carthage-build-xcframeworks: ## Run carthage build with use-xcframeworks
	@echo "Deleting Carthage artifacts..." && rm -rf Carthage
	carthage build --no-skip-current --use-xcframeworks

.PHONY: swift-build
swift-build: ## Run swift build
	swift package clean && swift build -c release

.PHONY: swift-build-linux
swift-build-linux: ## Run swift build on Linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) /bin/sh -c "swift package clean && swift build -c release"

.PHONY: bazel-build
bazel-build: ## Run bazel build
	./scripts/bazel-script.sh

.PHONY: bazel-build-linux
bazel-build-linux: ## Run bazel build on Linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION) ./scripts/bazel-script.sh

.PHONY: cmake-build
cmake-build: ## Run cmake build
	./scripts/cmake-script.sh

.PHONY: cmake-build-linux
cmake-build-linux: ## Run cmake build on Linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION)-focal ./scripts/cmake-script.sh

.PHONY: ninja-build
ninja-build: ## Run ninja build
	SCRIPT_TYPE=ninja ./scripts/cmake-script.sh

.PHONY: ninja-build-linux
ninja-build-linux: ## Run ninja build on Linux container
	docker run --rm --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION)-focal /bin/sh -c "SCRIPT_TYPE=ninja ./scripts/cmake-script.sh"

.PHONY: linux
linux: ## Run and login linux container
	docker run --rm -it --volume "$(CURDIR):/src" --workdir "/src" swift:$(SWIFT_VERSION)
