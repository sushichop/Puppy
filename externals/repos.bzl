load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _external_repos(_):
    http_archive(
        name = "com_github_apple_swift_log",
        urls = ["https://github.com/apple/swift-log/archive/refs/tags/1.14.0.tar.gz"],
        sha256 = "1c39eb866858d81d6a141e1887d70cbad8d6c5fb66011566c2e6952e3c700040",
        strip_prefix = "swift-log-1.14.0",
        build_file = "@com_github_sushichop_puppy//externals:logging.BUILD",
    )

external_repos = module_extension(implementation = _external_repos)
