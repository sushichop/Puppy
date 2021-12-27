import XCTest
@testable import Puppy

final class FileLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        Puppy.useDebug = true
    }

    override func tearDownWithError() throws {
        Puppy.useDebug = false
        try super.tearDownWithError()
    }

    func testFileLogger() throws {
        let fileURL = URL(fileURLWithPath: "./foo/bar.log").absoluteURL
        let directoryURL = URL(fileURLWithPath: "./foo").absoluteURL

        let fileLogger = try FileLogger("com.example.yourapp.filelogger", fileURL: fileURL)
        let log = Puppy()
        log.add(fileLogger)
        log.trace("\(Date()): TRACE message using FileLogger")
        log.verbose("\(Date()): VERBOSE message using FileLogger")

        try fileLogger.delete(directoryURL)
        log.remove(fileLogger)
    }

    #if os(Linux) || os(macOS)
    func testTildeFileLogger() throws {
        let directoryName = "~/puppy_" + UUID().uuidString.lowercased()
        let fileName = directoryName + "/foo.log"
        let directoryURL = URL(fileURLWithPath: (directoryName as NSString).expandingTildeInPath).absoluteURL
        let fileURL = URL(fileURLWithPath: (fileName as NSString).expandingTildeInPath).absoluteURL

        let fileLogger = try FileLogger("com.example.yourapp.filelogger.tilde", fileURL: fileURL)
        let log = Puppy()
        log.add(fileLogger)
        log.trace("Tilde, TRACE message using FileLogger")
        log.verbose("Tilde, VERBOSE message using FileLogger")

        try fileLogger.delete(directoryURL)
        log.remove(fileLogger)
    }
    #endif

    func testCheckFileType() throws {
        let emptyFileURL = URL(fileURLWithPath: "").absoluteURL     // file:///private/tmp/
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notfile0", fileURL: emptyFileURL)) { error in
            XCTAssertEqual(error as? FileError, .isNotFile(url: emptyFileURL))
        }

        let directoryURL = URL(fileURLWithPath: "./").absoluteURL   // file:///private/tmp/
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notfile1", fileURL: directoryURL)) { error in
            XCTAssertEqual(error as? FileError, .isNotFile(url: directoryURL))
        }
    }

    #if canImport(Darwin)
    func testCreatingError() throws {
        let fileURLNotAbleToCreateDirectory = URL(fileURLWithPath: "/foo/bar.log").absoluteURL  // file:///foo/bar.log
        let directoryURLNotAbleToCreateDirectory = URL(fileURLWithPath: "/foo/").absoluteURL    // file:///foo
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notcreatedirectory",
                                            fileURL: fileURLNotAbleToCreateDirectory)) { error in
            XCTAssertEqual(error as? FileError, .creatingDirectoryFailed(at: directoryURLNotAbleToCreateDirectory))
        }

        let fileURLNotAbleToCreateFile = URL(fileURLWithPath: "/foo.log").absoluteURL   // file:///foo.log
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notcreatefile",
                                            fileURL: fileURLNotAbleToCreateFile)) { error in
            XCTAssertEqual(error as? FileError, FileError.creatingFileFailed(at: fileURLNotAbleToCreateFile))
        }
    }
    #endif

    func testDeletingFile() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.deleting", fileURL: existentFileURL)

        try fileLogger.delete(existentFileURL)
        XCTAssertThrowsError(try fileLogger.delete(noExistentFileURL)) { error in
            XCTAssertEqual(error as? FileError, .deletingFailed(at: noExistentFileURL))
        }
    }

    func testFlushFile() throws {
        let flushFileURL = URL(fileURLWithPath: "./flush.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.flush", fileURL: flushFileURL, flushMode: .manual)
        let log = Puppy()
        log.add(fileLogger)
        log.trace("flush, TRACE message using FileLogger")
        log.verbose("flush, VERBOSE message using FileLogger")

        fileLogger.flush()
        try fileLogger.delete(flushFileURL)
        log.remove(fileLogger)
    }
}
