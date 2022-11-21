# Puppy

![Swift5.6+](https://img.shields.io/badge/Swift-5.6%2B-orange.svg?style=flat)
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

let console = ConsoleLogger("com.example.yourapp.console", logLevel: .info)
let fileURL = URL(fileURLWithPath: "./foo.log").absoluteURL
let file = FileLogger("com.example.yourapp.file",
                      logLevel: .info,
                      fileURL: fileURL,
                      filePermission: "600")  // Default permission is "640". 

var log = Puppy()
log.add(console)
log.add(file)

log.debug("DEBUG message")  // Will NOT be logged.
log.info("INFO message")    // Will be logged.
log.error("ERROR message")  // Will be logged.
```

### Use file log rotation

Logging to file and use log rotation feature.

```swift
import Puppy

class ViewController: UIViewController {
    let fileURL = URL(fileURLWithPath: "./logs/foo.log").absoluteURL
    let rotationConfig = RotationConfig(suffixExtension: .date_uuid,
                                        maxFileSize: 10 * 1024 * 1024,
                                        maxArchivedFilesCount: 3)
    let delegate = SampleFileRotationDelegate()
    let fileRotation = try! FileRotationLogger("com.example.yourapp.filerotation",
                                                fileURL: fileURL,
                                                rotationConfig: rotationConfig,
                                                delegate: delegate)

    override func viewDidLoad() {
        super.viewDidLoad()
        var log = Puppy()
        log.add(fileRotation)
        log.info("INFO message")
        log.warning("WARNING message")
    }
}

class SampleFileRotationDelegate: FileRotationLoggerDelegate {
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

### Use with [apple/swift-log](https://github.com/apple/swift-log/)

Logging to multiple transports(e.g. console and syslog) as a backend for `apple/swift-log`.

```swift
import Puppy
import Logging

let console = ConsoleLogger("com.example.yourapp.console")
let syslog = SystemLogger("com.example.yourapp.syslog")

var puppy = Puppy()
puppy.add(console)
puppy.add(syslog)

LoggingSystem.bootstrap {
    var handler = PuppyLogHandler(label: $0, puppy: puppy)
    // Set the logging level.
    handler.logLevel = .trace
    return handler
}

var log = Logger(label: "com.example.yourapp.swiftlog")

log.trace("TRACE message")  // Will be logged.
log.debug("DEBUG message")  // Will be logged.
```

Here is a practical example of using `Puppy` with [Vapor](https://vapor.codes), which uses `apple/swift-log` internally.

```swift
import App
import Vapor  // Vapor 4.67.4
import Puppy

let fileURL = URL(fileURLWithPath: "./server-logs/bar.log").absoluteURL
let rotationConfig = RotationConfig(suffixExtension: .numbering,
                                    maxFileSize: 30 * 1024 * 1024,
                                    maxArchivedFilesCount: 5)
let fileRotation = try FileRotationLogger("com.example.yourapp.server",
                                          fileURL: fileURL,
                                          rotationConfig: rotationConfig)
var puppy = Puppy()
puppy.add(fileRotation)

// https://docs.vapor.codes/basics/logging/
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env) { (logLevel) -> (String) -> LogHandler in
    return { label -> LogHandler in
        var handler = PuppyLogHandler(label: label, puppy: puppy)
        handler.logLevel = .info
        return handler
    }
}
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
```

### Customize the log format

Customize the log format using `Formattable` protocol. Logging to oslog for example.

```swift
import Puppy

class ViewController: UIViewController {
    let logFormat = LogFormatter()
    let oslog = OSLogger("com.yourapp.oslog", logFormat: logFormat)

    override func viewDidLoad() {
        super.viewDidLoad()
        var log = Puppy()
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

You can also create your own custom logger. The custom logger needs to conform to `Loggerable` protocol.

```swift
import Puppy

public class CustomLogger: Loggerable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil) {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
    }

    public func log(_ level: LogLevel, string: String) {
        // Implements the logging feature here.
    }
}
```

## License

Puppy is available under the [MIT license](http://www.opensource.org/licenses/mit-license). See the LICENSE file for details.
