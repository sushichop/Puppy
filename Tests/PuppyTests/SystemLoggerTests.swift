#if os(Linux)
import XCTest
import Puppy

final class SystemLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testSystemLogger() throws {
        let systemLogger = SystemLogger("com.example.yourapp.systemlogger")
        let log = Puppy()
        log.add(systemLogger)
        log.trace("TRACE message using SystemLogger")
        log.verbose("VERBOSE message using SystemLogger")
        log.debug("DEBUG message using SystemLogger")
        log.info("INFO message using SystemLogger")
        log.notice("NOTICE message using SystemLogger")
        log.warning("WARNING message using SystemLogger")
        log.error("ERROR message using SystemLogger")
        log.critical("CRITICAL message using SystemLogger")
        log.remove(systemLogger)
    }
}

#endif
