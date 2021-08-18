import XCTest
@testable import Puppy

class PuppyTests: XCTestCase {

    let log = Puppy.default

    override func setUpWithError() throws {
        try super.setUpWithError()
        log.removeAll()
    }

    override func tearDownWithError() throws {
        log.removeAll()
        try super.tearDownWithError()
    }

    func testEmojiAndColor() throws {
        let consoleLogger = ConsoleLogger("com.example.yourapp.consolelogger.emojicolor")
        consoleLogger.logLevel = .trace
        log.add(consoleLogger)
        log.trace("\(LogLevel.trace.emoji) TRACE message with emoji and color".colorize(LogLevel.trace.color))
        log.verbose("\(LogLevel.verbose.emoji) VERBOSE message with emoji and color".colorize(LogLevel.verbose.color))
        log.debug("\(LogLevel.debug.emoji) DEBUG message with emoji and color".colorize(LogLevel.debug.color))
        log.info("\(LogLevel.info.emoji) INFO message with emoji and color".colorize(LogLevel.info.color))
        log.notice("\(LogLevel.notice.emoji) NOTICE message with emoji and color".colorize(LogLevel.notice.color))
        log.warning("\(LogLevel.warning.emoji) WARNING message with emoji and color".colorize(LogLevel.warning.color))
        log.error("\(LogLevel.error.emoji) ERROR message with emoji and color".colorize(LogLevel.error.color))
        log.critical("\(LogLevel.critical.emoji) CRITICAL message with emoji and color".colorize(LogLevel.critical.color))
    }

    func testAllColors() {
        print("black".colorize(.black),
              "red".colorize(.red),
              "green".colorize(.green),
              "yellow".colorize(.yellow),
              "blue".colorize(.blue),
              "magenta".colorize(.magenta),
              "cyan".colorize(.cyan),
              "lightGray".colorize(.lightGray),
              "darkGray   ".colorize(.darkGray),
              "lightRed   ".colorize(.lightRed),
              "lightGreen ".colorize(.lightGreen),
              "lightYellow".colorize(.lightYellow),
              "lightBlue  ".colorize(.lightBlue),
              "lightCyan  ".colorize(.lightCyan),
              "white      ".colorize(.white),
              "42".colorize(.colorNumber(42))
        )
    }

    func testFileLoggerToStdout() throws {
            let log: Puppy = Puppy.default
            let fileLogger = FileLogger("label", file: FileHandle.standardOutput, callerCloses: true)
            log.add(fileLogger)
            log.info("This test output is directed to stdout.")
    }
}
