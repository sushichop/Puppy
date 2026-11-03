load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _external_repos(_):
    http_archive(
        name = "com_github_apple_swift_log",
        urls = ["https://github.com/apple/swift-log/archive/refs/tags/1.16.2.tar.gz"],
        sha256 = "0b6f1d7370e1b8549782cd70e2441228f12ab9ee9d72056f38b8c02a2ea72604",
        strip_prefix = "swift-log-1.16.2",
        build_file = "@com_github_sushichop_puppy//externals:logging.BUILD",
    )

external_repos = module_extension(implementation = _external_repos)
