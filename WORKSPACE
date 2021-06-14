load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

http_archive(
    name = "build_bazel_rules_swift",
    url = "https://github.com/bazelbuild/rules_swift/releases/download/0.23.0/rules_swift.0.23.0.tar.gz",
    sha256 = "f872c0388808c3f8de67e0c6d39b0beac4a65d7e07eff3ced123d0b102046fb6",
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
    url = "https://github.com/apple/swift-log/archive/refs/tags/1.4.2.tar.gz",
    sha256 = "de51662b35f47764b6e12e9f1d43e7de28f6dd64f05bc30a318cf978cf3bc473",
    strip_prefix = "swift-log-1.4.2",
    build_file = "//:Externals/BUILD.bazel",
)
