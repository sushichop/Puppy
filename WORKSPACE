load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

http_archive(
    name = "build_bazel_rules_swift",
    url = "https://github.com/bazelbuild/rules_swift/releases/download/1.2.0/rules_swift.1.2.0.tar.gz",
    sha256 = "51efdaf85e04e51174de76ef563f255451d5a5cd24c61ad902feeadafc7046d9",
)

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)

swift_rules_extra_dependencies()

http_archive(
    name = "swift-log",
    url = "https://github.com/apple/swift-log/archive/refs/tags/1.4.4.tar.gz",
    sha256 = "48fe66426c784c0c20031f15dc17faf9f4c9037c192bfac2f643f65cb2321ba0",
    strip_prefix = "swift-log-1.4.4",
    build_file = "//:Externals/BUILD.bazel",
)
