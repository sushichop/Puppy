load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _external_repos(_):
    http_archive(
        name = "com_github_apple_swift_log",
        urls = ["https://github.com/apple/swift-log/archive/refs/tags/1.15.0.tar.gz"],
        sha256 = "4c4753204d1ae9d9985e4c9bd9ed8325a505f24ff9c7d04068c1206173b1ead3",
        strip_prefix = "swift-log-1.15.0",
        build_file = "@com_github_sushichop_puppy//externals:logging.BUILD",
    )

external_repos = module_extension(implementation = _external_repos)
