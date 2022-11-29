import XCTest
import Puppy
#if canImport(Logging)
import Logging
#endif // canImport(Logging)

final class LogFormatterTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testLogFormatter() throws {
        let logFormat: LogFormatter = .init()
        let consoleLogger = ConsoleLogger("com.example.yourapp.consolelogger.logformatter", logFormat: logFormat)
        var log = Puppy()
        log.add(consoleLogger)
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

private struct LogFormatter: LogFormattable, Sendable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date)
        let fileName = fileName(file)
        let moduleName = moduleName(file)
        return "\(date) \(threadID) [\(level.emoji) \(level)] \(swiftLogInfo) \(moduleName)/\(fileName)#L.\(line) \(function) \(message)".colorize(level.color)
    }
}
