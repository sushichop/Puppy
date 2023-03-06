load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

http_archive(
    name = "build_bazel_rules_swift",
    url = "https://github.com/bazelbuild/rules_swift/releases/download/1.6.0/rules_swift.1.6.0.tar.gz",
    sha256 = "d25a3f11829d321e0afb78b17a06902321c27b83376b31e3481f0869c28e1660",
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
    url = "https://github.com/apple/swift-log/archive/refs/tags/1.5.2.tar.gz",
    sha256 = "dfea6e00235eaab492fd818fc5e4c387769618c6436e862b1d4a4d73bf6c0301",
    strip_prefix = "swift-log-1.5.2",
    build_file = "//:Externals/BUILD.bazel",
)
