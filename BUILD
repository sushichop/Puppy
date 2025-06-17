load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "c_puppy",
    srcs = ["Sources/CPuppy/src/CPuppy.c"],
    hdrs = ["Sources/CPuppy/include/CPuppy.h"],
    includes = ["Sources/CPuppy/include"],
    tags = ["swift_module=CPuppy"],
    visibility = ["//visibility:public"],
)

swift_library(
    name = "puppy",
    srcs = glob(["Sources/Puppy/**/*.swift"]),
    deps = [":c_puppy", "@com_github_apple_swift_log//:logging"],
    module_name = "Puppy",
    visibility = ["//visibility:public"],
)

swift_test(
    name = "puppy_tests",
    srcs = glob(["Tests/PuppyTests/**/*.swift"]),
    deps = [":puppy"],
    visibility = ["//visibility:private"],
    copts = ["-DBAZEL_TESTING"],
)
