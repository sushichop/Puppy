import XCTest
import Puppy

final class PuppyLogHandlerTests: XCTestCase {

    func testLoggingSystem() throws {
        #if canImport(Logging)

        // let bool1 = [:].isEmpty         // true
        // let bool2 = ["a": ""].isEmpty   // false
        // let bool3 = ["b": nil].isEmpty  // false

        let consoleLogger: ConsoleLogger = .init("com.example.yourapp.consolelogger.swiftlog", logLevel: .trace)
        let puppy = Puppy(loggers: [consoleLogger])

        LoggingSystem.bootstrap {
            var handler = PuppyLogHandler(label: $0, puppy: puppy)
            handler.logLevel = .trace
            return handler
        }

        var logger: Logger = .init(label: "com.example.yourapp.swiftlog")
        logger.trace("TRACE message using PuppyLogHandler")
        logger.debug("DEBUG message using PuppyLogHandler")
        logger[metadataKey: "keyA"] = "1"
        logger[metadataKey: "keyB"] = "abc"
        logger[metadataKey: "keyC"] = nil
        logger[metadataKey: "keyD"] = "true"
        logger.info("INFO message using PuppyLogHandler")
        let keyD = logger[metadataKey: "keyD"] ?? "keyD is nothing."
        logger.info("\(keyD)")
        logger.notice("NOTICE message using PuppyLogHandler")
        logger.warning("WARNING message using PuppyLogHandler", metadata: ["keyWARNING": "true"])
        logger.error("ERROR message using PuppyLogHandler", metadata: ["keyB": "DEF"])
        logger.critical("CRITICAL message using PuppyLogHandler")

        #endif // canImport(Logging)
    }
}
