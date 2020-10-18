# Puppy 🐶

![CI](https://github.com/sushichop/Puppy/workflows/CI/badge.svg)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sushichop/Puppy/blob/master/LICENSE)

![Swift5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg?style=flat)
[![Carthage](https://img.shields.io/badge/Carhage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)
![platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgray.svg?style=flat)
![platforms](https://img.shields.io/badge/Platforms-Linux-orange.svg?style=flat)

### **Puppy is a flexible logging library written in Swift.**

## Features

- Written in Swift.
- Supports console, file, syslog, and oslog as loggers.
- Support automatic log roration about file logger.
- Supports both Darwin and Linux.
- Supports apple/swift-log.

## Examples

**Logging to console and file and use file log rotation feature.**

You can basically use CocoaPods, Carthage, and Swift Package Manager for integration.

```swift
let console = ConsoleLogger("com.example.yourapp.consolelogger")
let fileURL = URL(fileURLWithPath: "./rotation/foo.log").absoluteURL
let fileRotation = try FileRotationLogger("com.example.yourapp.filerotationlogger",
                                          fileURL: fileURL)

fileRotation.maxFileSize = 10 * 1024 * 1024
fileRotation.maxArchivedFilesCount = 5

let log = Puppy()
log.add(console)
log.add(fileRotation)

log.info("INFO message")
log.warning("WARNING message")
```

**Logging to console and syslog using `apple/swift-log`.**

You can use CocoaPods and Swift Package Manager for integration.
(`apple/swift-log` does not support Carthage integration.)

```swift
let console = SystemLogger("com.example.yourapp.consolelogger")
let syslog = SystemLogger("com.example.yourapp.systemlogger")

let puppy = Puppy.default
puppy.add(console)
puppy.add(syslog)

LoggingSystem.bootstrap {
    var handler = PuppyLogHandler(label: $0, puppy: puppy)
    handler.logLevel = .trace
    return handler
}

log.trace("TRACE message")
log.debug("DEBUG message")
```


## License

Puppy is available under the [MIT license](http://www.opensource.org/licenses/mit-license). See the LICENSE file for details.
