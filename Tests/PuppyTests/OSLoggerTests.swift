import XCTest
import Puppy

final class OSLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testOSLogger() async throws {
        #if canImport(Darwin)
        let osLogger: OSLogger = .init("com.example.yourapp.oslogger")
        var log = Puppy()
        log.add(osLogger)
        await log.trace("TRACE message using OSLogger")
        await log.verbose("VERBOSE message using OSLogger")
        await log.debug("DEBUG message using OSLogger")
        await log.info("INFO message using OSLogger")
        await log.notice("NOTICE message using OSLogger")
        await log.warning("WARNING message using OSLogger")
        await log.error("ERROR message using OSLogger")
        await log.critical("CRITICAL message using OSLogger")
        log.remove(osLogger)
        #endif // canImport(Darwin)
    }
}
