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

    func testLogFormatter() async throws {
        let logFormat: LogFormatter = .init()
        let consoleLogger = ConsoleLogger("com.example.yourapp.consolelogger.logformatter", logFormat: logFormat)
        var log = Puppy()
        log.add(consoleLogger)
        await log.trace("TRACE message")
        await log.verbose("VERBOSE message")
        await log.debug("DEBUG message")
        await log.info("INFO message")
        await log.notice("NOTICE message")
        await log.warning("WARNING message")
        await log.error("ERROR message")
        await log.critical("CRITICAL message")
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
