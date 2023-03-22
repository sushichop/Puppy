## [x.y.z](https://github.com/sushichop/Puppy/releases/tag/x.y.z) (yyyy-mm-dd)

- Workaround for `pod lib lint` on watchOS is no longer needed. [#86](https://github.com/sushichop/Puppy/pull/86)

## [0.7.0](https://github.com/sushichop/Puppy/releases/tag/0.7.0) (2023-03-13)

- Add different error handling behaviors for disk writing errors. [#75](https://github.com/sushichop/Puppy/pull/75)
- Make `logMessage` method public. [#77](https://github.com/sushichop/Puppy/pull/77)
- Add method to support flushing log message. [#79](https://github.com/sushichop/Puppy/pull/79)
- Make `dateFormat` function more efficient. [#81](https://github.com/sushichop/Puppy/pull/81)
- Update `Logging` module to 1.5.2 or later. [#82](https://github.com/sushichop/Puppy/pull/82)
- Export `Logging` module. [#83](https://github.com/sushichop/Puppy/pull/83)
- Use Swift 5.7.2 and Xcode 14.2. [#84](https://github.com/sushichop/Puppy/pull/84)

## [0.6.0](https://github.com/sushichop/Puppy/releases/tag/0.6.0) (2022-11-29)

- Disable bitcode. [#54](https://github.com/sushichop/Puppy/pull/54)
- Update platform versions. [#55](https://github.com/sushichop/Puppy/pull/55)
- Update to Xcode 14.0.1 and Swift 5.6 or later. [#56](https://github.com/sushichop/Puppy/pull/56)
- Still use Xcode 13.4.1 for executing `pod lib lint`. [#57](https://github.com/sushichop/Puppy/pull/57)
- Remove a property of type FileHandle. [#58](https://github.com/sushichop/Puppy/pull/58)
- Remove the argument named `asynchronous`. [#59](https://github.com/sushichop/Puppy/pull/59)
- Remove and change the properties. [#60](https://github.com/sushichop/Puppy/pull/60)
- Change minimum platform versions. [#61](https://github.com/sushichop/Puppy/pull/61)
- Adopt `Sendable` and `Loggerable`. [#62](https://github.com/sushichop/Puppy/pull/62)
- Remove the dependency in podspec. [#66](https://github.com/sushichop/Puppy/pull/66)
- Update to `Xcode 14.1`. [#69](https://github.com/sushichop/Puppy/pull/69)
- Use `#fileID` instead of `#file`. [#70](https://github.com/sushichop/Puppy/pull/70)
- Add another example of using `Puppy` with [Vapor](https://vapor.codes). [#71](https://github.com/sushichop/Puppy/pull/71)
- Use `struct` instead of `class`. [#72](https://github.com/sushichop/Puppy/pull/72)

## [0.5.1](https://github.com/sushichop/Puppy/releases/tag/0.5.1) (2022-09-24)

- Use macro for debugging. [#50](https://github.com/sushichop/Puppy/pull/50)
- Move `Hashable` to `Loggerable`. [#51](https://github.com/sushichop/Puppy/pull/51)
- Add a missing method. [#52](https://github.com/sushichop/Puppy/pull/52)
- Suppress `Run script build phase` warning about Swiftlint. [#53](https://github.com/sushichop/Puppy/pull/53)

## [0.5.0](https://github.com/sushichop/Puppy/releases/tag/0.5.0) (2022-02-28)

- Remove concurrency features. [#39](https://github.com/sushichop/Puppy/pull/39)
- Fix the default rotation type to `numbering`. [#40](https://github.com/sushichop/Puppy/pull/40)
- Change the type of intPermission to `UInt16`. [#41](https://github.com/sushichop/Puppy/pull/41)
- Output a message prompting to override. [#42](https://github.com/sushichop/Puppy/pull/42)
- Use String type for filePermission. [#43](https://github.com/sushichop/Puppy/pull/43)
- Add error descriptions to `FileError`. [#44](https://github.com/sushichop/Puppy/pull/44)
- Support Windows. [#45](https://github.com/sushichop/Puppy/pull/45)
- Update GitHub Actions. [#46](https://github.com/sushichop/Puppy/pull/46)

## [0.4.0](https://github.com/sushichop/Puppy/releases/tag/0.4.0) (2022-01-31)

- `FileRotatonLogger` inherits `FileLogger`. [#29](https://github.com/sushichop/Puppy/pull/29)
- Add asynchronous methods for `delete` and `flush`. [#30](https://github.com/sushichop/Puppy/pull/30)
- Add `test_spec` in `podspec`. [#31](https://github.com/sushichop/Puppy/pull/31)
- Add suffix extension types for `FileRotationLogger`. [#32](https://github.com/sushichop/Puppy/pull/32)
- FileRotationLoggerDelegate Fix Spelling. [#34](https://github.com/sushichop/Puppy/pull/34)
- Add option for file permission. [#36](https://github.com/sushichop/Puppy/pull/36)
- Import more precisely. [#38](https://github.com/sushichop/Puppy/pull/38)

## [0.3.1](https://github.com/sushichop/Puppy/releases/tag/0.3.1) (2021-08-18)

- Add file required only for Swift 5.3.x or before on Linux. [25](https://github.com/sushichop/Puppy/pull/25)

## [0.3.0](https://github.com/sushichop/Puppy/releases/tag/0.3.0) (2021-08-07)

- Update `cmake-build` for Linux. [#19](https://github.com/sushichop/Puppy/pull/19)
- Workaround for `carthage build` in both Xcode 12 and 13. [#20](https://github.com/sushichop/Puppy/pull/20)
- Follow up `Integrate modules into Xcode`. [#22](https://github.com/sushichop/Puppy/pull/22)
- Make `BaseLogger` inheritable outside of the module(`Puppy`). [#23](https://github.com/sushichop/Puppy/pull/23)

## [0.2.0](https://github.com/sushichop/Puppy/releases/tag/0.2.0) (2021-06-17)

- Instantiate `DispatchQueue` and add an argument named of `asynchronous`. [#9](https://github.com/sushichop/Puppy/pull/9)
- Remove colons from log rotation file name(extension). [#11](https://github.com/sushichop/Puppy/pull/11)
- Use `AnyObject` for protocol inheritance instead of `class`. [#13](https://github.com/sushichop/Puppy/pull/13)
- Add `carthage-build-xcframeworks`. [#14](https://github.com/sushichop/Puppy/pull/14)
- Specify Linux platform. [#15](https://github.com/sushichop/Puppy/pull/15)
- Integrate modules in Xcode and Podspec. [#16](https://github.com/sushichop/Puppy/pull/16)
- Add `bazel-build`. [#17](https://github.com/sushichop/Puppy/pull/17)
- Add `cmake/ninja-build`. [#18](https://github.com/sushichop/Puppy/pull/18)

## [0.1.2](https://github.com/sushichop/Puppy/releases/tag/0.1.2) (2020-12-05)

- Support new API about FileHandle. [#7](https://github.com/sushichop/Puppy/pull/7)

## [0.1.1](https://github.com/sushichop/Puppy/releases/tag/0.1.1) (2020-10-20)

- Fix access level issue for use as a library. [#4](https://github.com/sushichop/Puppy/pull/4)

## [0.1.0](https://github.com/sushichop/Puppy/releases/tag/0.1.0) (2020-10-18)

- First release.
