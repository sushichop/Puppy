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

    func testDateFormatWithFormatter() throws {
        struct LogFormatter: LogFormattable {
            private let dateFormat = DateFormatter()

            func formatMessage(_ level: LogLevel, message: String, tag: String, function: String,
                               file: String, line: UInt, swiftLogInfo: [String: String],
                               label: String, date: Date, threadID: UInt64) -> String {
                let date = dateFormatter(date, withFormatter: dateFormat)
                return "\(date) \(message)"
            }
        }

        let logFormat = LogFormatter()
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

    // 0.000144s on a 2018 M1 Macbook Pro
    func testMeasureDateFormatWithParams() throws {
        let dateFormat = DateFormatter()
        self.measure {
            _ = dateFormatter(Date(), withFormatter: dateFormat, locale: "en_US_POSIX", dateFormat: "yyyy-MM-dd", timeZone: "GMT")
        }
    }

    // 0.0000672s on a 2018 M1 Macbook Pro
    func testMeasureDateFormat() throws {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.timeZone = TimeZone(identifier: "GMT")
        dateFormat.locale = Locale(identifier: "en_US_POSIX")

        self.measure {
            _ = dateFormatter(Date(), withFormatter: dateFormat)
        }
    }
}

private struct LogFormatter: LogFormattable, Sendable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date, withFormatter: DateFormatter())
        let fileName = fileName(file)
        let moduleName = moduleName(file)
        return "\(date) \(threadID) [\(level.emoji) \(level)] \(swiftLogInfo) \(moduleName)/\(fileName)#L.\(line) \(function) \(message)".colorize(level.color)
    }
}
