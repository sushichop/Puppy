import XCTest
import Puppy

final class BaseLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testBaseLogger() throws {
        let baseLogger = BaseLogger("com.example.yourapp.baselogger")
        let log = Puppy()
        log.add(baseLogger, withLevel: .trace)

        log.trace("TRACE message using BaseLogger")
        log.debug("DEBUG message using BaseLogger")
        baseLogger.logLevel = .notice
        log.info("🐛 INFO message but THIS MESSAGE MUST NOT DISPLAYED using BaseLogger")
        log.notice("NOTICE message using BaseLogger")
        baseLogger.enabled = false
        log.notice("🐛 NOTICE message but THIS MESSAGE MUST NOT DISPLAYED using BaseLogger")

        log.remove(baseLogger)
    }

    func testMockLogger() throws {
        let mockLogger = MockLogger("com.example.yourapp.mocklogger.async")

        let log = Puppy()
        log.add(mockLogger, withLevel: .debug)
        log.debug("DEBUG message")
        log.warning("WARNING message")

        let exp = XCTestExpectation(description: "MockLogger Asynchronous")
        mockLogger.queue.async {
            XCTAssertEqual(mockLogger.invokedLogCount, 2)
            XCTAssertEqual(mockLogger.invokedLogLevels, [.debug, .warning])
            XCTAssertEqual(mockLogger.invokedLogStrings, ["DEBUG message", "WARNING message"])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        log.remove(mockLogger)
    }

    func testMockLogFormatter() throws {
        let mockLogger = MockLogger("com.example.yourapp.mocklogger.logformatter")
        mockLogger.logLevel = .info
        let mockLogFormatter = MockLogFormatter()
        mockLogger.format = mockLogFormatter
        let log = Puppy()
        log.add(mockLogger)
        log.debug("DEBUG message")
        log.warning("WARNING message")
        log.error("ERROR message", tag: "error-tag")

        let exp = XCTestExpectation(description: "MockLogger LogFormatter")
        mockLogger.queue.async {
            XCTAssertEqual(mockLogger.invokedLogCount, 2)
            XCTAssertEqual(mockLogger.invokedLogLevels, [.warning, .error])
            XCTAssertEqual(mockLogger.invokedLogStrings, [
                "MockLogFormatter WARNING message",
                "MockLogFormatter ERROR message",
            ])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageCount, 2)
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageLevels, [.warning, .error])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageMessages, [
                "WARNING message",
                "ERROR message",
            ])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageTags, ["", "error-tag"])
            XCTAssertEqual(mockLogFormatter.invokedFormatMessageLabel, "com.example.yourapp.mocklogger.logformatter")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        log.remove(mockLogger)
    }
}
