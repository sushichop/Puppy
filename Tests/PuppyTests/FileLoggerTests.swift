import XCTest
import Puppy

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

        _ = fileLogger.delete(directoryURL)
        log.remove(fileLogger)
    }

    #if os(macOS) || os(Linux)
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

        _ = fileLogger.delete(directoryURL)
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
            XCTAssertEqual(error as? FileError, .creatingFileFailed(at: fileURLNotAbleToCreateFile))
        }
    }
    #endif

    func testDeletingFile() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.deleting", fileURL: existentFileURL)

        let resultSuccess = fileLogger.delete(existentFileURL)
        switch resultSuccess {
        case .success(let url):
            XCTAssertEqual(existentFileURL, url)
        case .failure:
            XCTFail("shuould not be failed, but was failed")
        }

        let resultFailure = fileLogger.delete(noExistentFileURL)
        switch resultFailure {
        case .success:
            XCTFail("should not be successful, but was successful")
        case .failure(let error):
            XCTAssertEqual(error as FileDeletingError, .failed(at: noExistentFileURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete the file: \(noExistentFileURL)")
        }
    }

    func testDeletingFileAsync() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-async.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-async.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.deletingasync", fileURL: existentFileURL)

        let expSuccess = expectation(description: "expSuccessAsyncResult")
        fileLogger.delete(existentFileURL) { result in
            switch result {
            case .success(let url):
                XCTAssertEqual(existentFileURL, url)
                expSuccess.fulfill()
            case .failure:
                XCTFail("shuould not be failed, but was failed")
            }
        }

        let expFailure = expectation(description: "expFailureAsyncResult")
        fileLogger.delete(noExistentFileURL) { result in
            switch result {
            case .success:
                XCTFail("should not be successful, but was successful")
            case .failure(let error):
                XCTAssertEqual(error as FileDeletingError, .failed(at: noExistentFileURL))
                XCTAssertEqual(error.localizedDescription, "failed to delete the file: \(noExistentFileURL)")
                expFailure.fulfill()
            }
        }

        wait(for: [expSuccess, expFailure], timeout: 5.0)
    }

    func testDeletingFileResultConversion() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-result-conversion.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-result-conversion.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.deletingresultconversion", fileURL: existentFileURL)

        do {
            let url = try fileLogger.delete(existentFileURL).get()
            XCTAssertEqual(url, existentFileURL)
        } catch {
            XCTFail("error should not be thrown, but it was thrown: \(error.localizedDescription)")
        }

        do {
            _ = try fileLogger.delete(noExistentFileURL).get()
            XCTFail("error should be thrown while awaiting, but it was not thrown")
        } catch {
            XCTAssertEqual(error as? FileDeletingError, .failed(at: noExistentFileURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete the file: \(noExistentFileURL)")
        }
    }

    func testDeletingFileAsyncResultConversion() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-async-result-conversion.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-async-result-conversion.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.deletingasyncresultconversion", fileURL: existentFileURL)

        let expSuccess = expectation(description: "expSuccessAsync")
        fileLogger.delete(existentFileURL) { result in
            do {
                let url = try result.get()
                XCTAssertEqual(url, existentFileURL)
                expSuccess.fulfill()
            } catch {
                XCTFail("error should not be thrown, but it was thrown: \(error.localizedDescription)")
            }
        }

        let expFailure = expectation(description: "expFailureAsync")
        fileLogger.delete(noExistentFileURL) { result in
            do {
                _ = try result.get()
                XCTFail("error should be thrown while awaiting, but it was not thrown")
            } catch {
                XCTAssertEqual(error as? FileDeletingError, .failed(at: noExistentFileURL))
                XCTAssertEqual(error.localizedDescription, "failed to delete the file: \(noExistentFileURL)")
                expFailure.fulfill()
            }
        }

        wait(for: [expSuccess, expFailure], timeout: 5.0)
    }

    func testFlushFile() throws {
        let flushFileURL = URL(fileURLWithPath: "./flush.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.flush", fileURL: flushFileURL, flushMode: .manual)
        let log = Puppy()
        log.add(fileLogger)
        log.trace("flush, TRACE message using FileLogger")
        log.verbose("flush, VERBOSE message using FileLogger")

        fileLogger.flush()
        _ = fileLogger.delete(flushFileURL)
        log.remove(fileLogger)
    }

    func testFlushFileAsync() throws {
        let fileURL = URL(fileURLWithPath: "./flush-async.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.flushasync", fileURL: fileURL, flushMode: .manual)
        let log = Puppy()
        log.add(fileLogger)
        log.trace("flushAsync, TRACE message using FileLogger")
        log.verbose("flushAsync, VERBOSE message using FileLogger")

        let exp = expectation(description: "flushAsync")
        fileLogger.flush {
            // Do NOT add a task into the same queue synchronously.
            // _ = fileLogger.delete(fileURL)
            fileLogger.delete(fileURL) { _ in
                log.remove(fileLogger)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 5.0)
    }

    func testFilePermssion() throws {
        let fileURL = URL(fileURLWithPath: "./permisson600.log").absoluteURL
        let fileLogger = try FileLogger("com.example.yourapp.filelogger.permisson600", fileURL: fileURL, filePermisson: "600")
        let log = Puppy()
        log.add(fileLogger)
        log.trace("permisson, TRACE message using FileLogger")
        log.verbose("permisson, VERBOSE message using FileLogger")
        fileLogger.flush()

        let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        // swiftlint:disable force_cast
        let permission = attribute[FileAttributeKey.posixPermissions] as! UInt16
        // swiftlint:enable force_cast
        let expectedPermission = UInt16("600", radix: 8)!
        XCTAssertEqual(permission, expectedPermission)

        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
    }

    func testFilePermissionError() throws {
        let permission800FileURL = URL(fileURLWithPath: "./permisson800.log").absoluteURL
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.permisson800", fileURL: permission800FileURL, filePermisson: "800")) { error in
            XCTAssertEqual(error as? FileError, .invalidPermssion("800"))
        }

        let permissionABCFileURL = URL(fileURLWithPath: "./permissonABC.log").absoluteURL
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.permissonABC", fileURL: permissionABCFileURL, filePermisson: "ABC")) { error in
            XCTAssertEqual(error as? FileError, .invalidPermssion("ABC"))
        }
    }
}
