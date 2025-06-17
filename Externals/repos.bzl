load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _external_repos(_):
    http_archive(
        name = "com_github_apple_swift_log",
        urls = ["https://github.com/apple/swift-log/archive/refs/tags/1.6.3.tar.gz"],
        sha256 = "5eaed6614cfaad882b8a0b5cb5d2177b533056b469ba431ad3f375193d370b70",
        strip_prefix = "swift-log-1.6.3",
        build_file = "@com_github_sushichop_puppy//externals:logging.BUILD",
    )

external_repos = module_extension(implementation = _external_repos)
