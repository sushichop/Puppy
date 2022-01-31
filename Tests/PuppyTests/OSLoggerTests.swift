#if canImport(Darwin)
import XCTest
import Puppy

final class OSLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testOSLogger() throws {
        let osLogger = OSLogger("com.example.yourapp.oslogger")
        let log = Puppy()
        log.add(osLogger)
        log.trace("TRACE message using OSLogger")
        log.verbose("VERBOSE message using OSLogger")
        log.debug("DEBUG message using OSLogger")
        log.info("INFO message using OSLogger")
        log.notice("NOTICE message using OSLogger")
        log.warning("WARNING message using OSLogger")
        log.error("ERROR message using OSLogger")
        log.critical("CRITICAL message using OSLogger")
        log.remove(osLogger)
    }
}

#endif
