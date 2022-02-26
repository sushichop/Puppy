# Puppy

![Swift5.4+](https://img.shields.io/badge/Swift-5.4%2B-orange.svg?style=flat)
[![release](https://img.shields.io/github/v/release/sushichop/Puppy.svg?color=blue)](https://github.com/sushichop/Puppy/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/Puppy.svg?color=blue)](https://cocoapods.org/pods/Puppy)
![CI](https://github.com/sushichop/Puppy/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/sushichop/Puppy/branch/main/graph/badge.svg)](https://codecov.io/gh/sushichop/Puppy)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sushichop/Puppy/blob/master/LICENSE)

![platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux%20%7C%20Windows-orange.svg?style=flat)
![SwiftPM|CMake|Bazel|Carthage](https://img.shields.io/badge/SwiftPM%20%7C%20CMake%20%7C%20Bazel%20%7C%20Carthage-compatible-4BC51D.svg?style=flat)

### **Puppy is a flexible logging library written in Swift** 🐶

It supports multiple transports(console, file, syslog, and oslog) as loggers. It not only works alone, but also as a backend for [apple/swift-log](https://github.com/apple/swift-log/).

Furthermore, it has file log rotation feature and you can also customize the log format as you like. And it supports **cross-platform(Darwin, Linux, and Windows)**.

## Features

- Written in Swift.
- Supports cross-platform(Darwin, Linux, and Windows).
- Supports console, file, syslog, and oslog as loggers.
- Supports automatic log rotation about file logger.
- Also Works as a backend for `apple/swift-log`.

## Examples

### Basic Usage

Logging to mutliple transports(e.g. console and file). It is recommended that the first argument of each logger be a unique reverse-order FQDN since it is also used internally for a `DispatchQueue`'s label.

```Swift
import Puppy

let console = ConsoleLogger("com.example.yourapp.console")
let fileURL = URL(fileURLWithPath: "./foo.log").absoluteURL
let file = FileLogger("com.example.yourapp.file",
                      fileURL: fileURL,
                      filePermission: "600")  // Default permission is "640". 

let log = Puppy()
// Set the logging level.
log.add(console, withLevel: .warning)
log.add(file, withLevel: .warning)

log.debug("DEBUG message")  // Will NOT be logged.
log.error("ERROR message")  // Will be logged.
```

### Use with [apple/swift-log](https://github.com/apple/swift-log/)

Logging to mutliple transports(e.g. console and syslog) as a backend for `apple/swift-log`.

```swift
import Puppy
import Logging

let console = ConsoleLogger("com.example.yourapp.console")
let syslog = SystemLogger("com.example.yourapp.syslog")

let puppy = Puppy.default
puppy.add(console)
puppy.add(syslog)

LoggingSystem.bootstrap {
    var handler = PuppyLogHandler(label: $0, puppy: puppy)
    // Set the logging level.
    handler.logLevel = .trace
    return handler
}

let log = Logger(label: "com.example.yourapp.swiftlog")

log.trace("TRACE message")  // Will be logged.
log.debug("DEBUG message")  // Will be logged.
```

### Use file log rotation

Logging to file and use log rotation feature.

```swift
import Puppy

class ViewController: UIViewController {
    let delegate = SampleFileRotationDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileRotation = try! FileRotationLogger("com.example.yourapp.filerotation",
                                                   fileURL: "./logs/foo.log")
        fileRotation.suffixExtension = .date_uuid   // Default option is `.numbering`.
        fileRotation.maxFileSize = 10 * 1024 * 1024
        fileRotation.maxArchivedFilesCount = 5
        fileRotation.delegate = delegate
        let log = Puppy()
        log.add(fileRotation)
        log.info("INFO message")
        log.warning("WARNING message")
    }
}

class SampleFileRotationDelegate: FileRotationLoggerDeletate {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger,
                            didArchiveFileURL: URL, toFileURL: URL) {
        print("didArchiveFileURL: \(didArchiveFileURL), toFileURL: \(toFileURL)")
    }
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger,
                            didRemoveArchivedFileURL: URL) {
        print("didRemoveArchivedFileURL: \(didRemoveArchivedFileURL)")
    }
}
```

### Customize the log format

Customize the log format using `Formattable` protocol. Logging to oslog for example.

```swift
import Puppy

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let oslog = OSLogger("com.yourapp.oslog")
        oslog.format = LogFormatter()
        let log = Puppy()
        log.add(oslog)
        log.info("INFO message")
        log.warning("WARNING message")
    }
}

class LogFormatter: LogFormattable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String,
                       file: String, line: UInt, swiftLogInfo: [String : String],
                       label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date)
        let file = shortFileName(file)
        return "\(date) \(threadID) [\(level.emoji) \(level)] \(file)#L.\(line) \(function) \(message)"
    }
}
```

### Create a custom logger

You can create your own custom logger. All you have to do is inherit `BaseLogger` class and override `log(_:string:)` method.

```swift
import Puppy

class CustomLogger: BaseLogger {
    override func log(_ level: LogLevel, string: String) {
        // Implements the logging feature here.
    }
}
```

## License

Puppy is available under the [MIT license](http://www.opensource.org/licenses/mit-license). See the LICENSE file for details.
