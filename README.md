# Puppy 🐶

[![release](https://img.shields.io/github/v/release/sushichop/Puppy.svg?color=blue)](https://github.com/sushichop/Puppy/releases)
![CI](https://github.com/sushichop/Puppy/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/sushichop/Puppy/branch/main/graph/badge.svg)](https://codecov.io/gh/sushichop/Puppy)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sushichop/Puppy/blob/master/LICENSE)

![Swift5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg?style=flat)
[![CocoaPods](https://img.shields.io/cocoapods/v/Puppy.svg?style=flat)](https://cocoapods.org/pods/Puppy)
[![Carthage](https://img.shields.io/badge/Carhage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)
![platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgray.svg?style=flat)
![platforms](https://img.shields.io/badge/Platforms-Linux-orange.svg?style=flat)

### **Puppy is a flexible logging library written in Swift.**

## Features

- Written in Swift.
- Supports console, file, syslog, and oslog as loggers.
- Supports automatic log rotation about file logger.
- Supports both Darwin and Linux.
- Supports [apple/swift-log](https://github.com/apple/swift-log/).

## Examples

**Logging to console and file, then use log rotation feature about file.**

You can basically use CocoaPods, Carthage, and Swift Package Manager for integration.

```swift
import Puppy

let console = ConsoleLogger(bundleID + ".consolelogger")

let appSupportDirURL = try! FileManager.default.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
let bundleID = Bundle.main.bundleIdentifier!
let logfileURL = appSupportDirURL
    .appendingPathComponent(bundleID, isDirectory: true)
    .appendingPathComponent("rotation.log")

let fileRotation = try! FileRotationLogger(bundleID + ".filerotationlogger",
                                           fileURL: logfileURL)
fileRotation.maxFileSize = 10 * 1024 * 1024
fileRotation.maxArchivedFilesCount = 5

let log = Puppy()
log.add(fileRotation)
log.add(console)

log.info("INFO message")
log.warning("WARNING message")

```

**Logging to console and syslog using `apple/swift-log`.**

You can use CocoaPods and Swift Package Manager for integration.

```swift
import Puppy
import Logging

let bundleID = Bundle.main.bundleIdentifier!
let console = ConsoleLogger(bundleID + ".consolelogger")
let syslog = SystemLogger(bundleID + ".systemlogger")

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
