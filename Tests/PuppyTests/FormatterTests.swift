import XCTest
@testable import Puppy
#if canImport(Logging)
import Logging
#endif

class FormatterTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testFormatter() throws {
        let consoleLogger = ConsoleLogger("com.example.yourapp.consolelogger.logformatter")
        consoleLogger.format = LogFormatter()
        let log = Puppy()
        log.add(consoleLogger, withLevel: .trace)
        log.trace("TRACE message")
        log.verbose("VERBOSE message")
        log.debug("DEBUG message")
        log.info("INFO message")
        log.notice("NOTICE message")
        log.warning("WARNING message")
        log.error("ERROR message")
        log.critical("CRITICAL message")
        log.remove(consoleLogger)
    }
}

class LogFormatter: LogFormattable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date)
        let file = shortFileName(file)
        return "\(date) \(threadID) [\(level.emoji) \(level)] \(swiftLogInfo) \(file)#L.\(line) \(function) \(message)".colorize(level.color)
    }
}
