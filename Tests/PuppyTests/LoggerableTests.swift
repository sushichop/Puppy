import XCTest
import Puppy

final class LoggerableTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testLoggerableLogLevel() async throws {
        let mockLogger: MockLogger = .init("com.example.yourapp.mocklogger.loglevel", logLevel: .debug)
        var log = Puppy()
        log.add(mockLogger)

        await log.trace("TRACE message")
        await log.verbose("VERBOSE message")

        await log.debug("DEBUG message")
        await log.info("INFO message")
        await log.notice("NOTICE message")

        let exp = XCTestExpectation(description: "MockLogger LogLevel")
        mockLogger.queue.async {
            XCTAssertTrue(mockLogger.invokedLog)
            XCTAssertEqual(mockLogger.invokedLogCount, 3)
            XCTAssertEqual(mockLogger.invokedLogLevels, [.debug, .info, .notice])
            XCTAssertEqual(mockLogger.invokedLogStrings, ["DEBUG message", "INFO message", "NOTICE message"])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        log.remove(mockLogger)
    }

    func testLoggerableLogFormat() async throws {
        let mockLogFormatter: MockLogFormatter = .init()
        let mockLogger: MockLogger = .init("com.example.yourapp.mocklogger.logformat", logLevel: .error, logFormat: mockLogFormatter)
        var log = Puppy(loggers: [mockLogger])

        await log.notice("NOTICE message")
        await log.warning("WARNING message")

        await log.error("ERROR message")
        await log.critical("CRITICAL message", tag: "critical-tag")

        let exp = XCTestExpectation(description: "MockLogger LogFormatter")
        mockLogger.queue.async {
            XCTAssertEqual(mockLogger.invokedLogCount, 2)
            XCTAssertEqual(mockLogger.invokedLogLevels, [.error, .critical])
            XCTAssertEqual(mockLogger.invokedLogStrings, [
                "MockLogFormatter ERROR message",
                "MockLogFormatter CRITICAL message",
            ])

            XCTAssertEqual(mockLogFormatter.invokedFormatMessageCount, 2)
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageLevels, [.error, .critical])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageMessages, [
                "ERROR message",
                "CRITICAL message",
            ])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageTags, ["", "critical-tag"])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageModuleNames, ["PuppyTests", "PuppyTests"])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageFileNames, ["LoggerableTests.swift", "LoggerableTests.swift"])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageSwiftLogInfo, ["source": ""])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageLabel, "com.example.yourapp.mocklogger.logformat")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        log.removeAll()
    }
}
