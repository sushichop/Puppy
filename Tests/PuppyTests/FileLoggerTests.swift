import XCTest
import Puppy

final class FileLoggerTests: XCTestCase {

    func testFileLogger() throws {
        let fileURL = URL(fileURLWithPath: "./foo/bar.log").absoluteURL
        let directoryURL = URL(fileURLWithPath: "./foo").absoluteURL

        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger", fileURL: fileURL)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("\(Date()): TRACE message using FileLogger")
        log.verbose("\(Date()): VERBOSE message using FileLogger")

        _ = fileLogger.delete(directoryURL)
        log.remove(fileLogger)
    }

    func testTildeFileLogger() throws {
        #if os(macOS) || os(Linux)
        // Skips in bazel test.
        if ProcessInfo.processInfo.environment["TEST_WORKSPACE"] != nil {
            return
        }
        let directoryName = "~/puppy_" + UUID().uuidString.lowercased()
        let fileName = directoryName + "/foo.log"
        let directoryURL = URL(fileURLWithPath: (directoryName as NSString).expandingTildeInPath).absoluteURL
        let fileURL = URL(fileURLWithPath: (fileName as NSString).expandingTildeInPath).absoluteURL

        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.tilde", fileURL: fileURL)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("Tilde, TRACE message using FileLogger")
        log.verbose("Tilde, VERBOSE message using FileLogger")

        _ = fileLogger.delete(directoryURL)
        log.remove(fileLogger)
        #endif // os(macOS) || os(Linux)
    }

    func testCheckFileType() throws {
        let emptyFileURL = URL(fileURLWithPath: "").absoluteURL     // file:///private/tmp/
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notfile0", fileURL: emptyFileURL)) { error in
            XCTAssertEqual(error as? FileError, .isNotFile(url: emptyFileURL))
            XCTAssertEqual(error.localizedDescription, "\(emptyFileURL) is not a file")
        }

        let directoryURL = URL(fileURLWithPath: "./").absoluteURL   // file:///private/tmp/
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notfile1", fileURL: directoryURL)) { error in
            XCTAssertEqual(error as? FileError, .isNotFile(url: directoryURL))
            XCTAssertEqual(error.localizedDescription, "\(directoryURL) is not a file")
        }
    }

    func testFilePermission() throws {
        let fileURL = URL(fileURLWithPath: "./permission600.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.permission600", fileURL: fileURL, filePermission: "600")
        var log = Puppy()
        log.add(fileLogger)
        log.trace("permission, TRACE message using FileLogger")
        log.verbose("permission, VERBOSE message using FileLogger")
        fileLogger.flush(fileURL)

        let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        // swiftlint:disable force_cast
        let permission = attribute[FileAttributeKey.posixPermissions] as! UInt16
        // swiftlint:enable force_cast

        let expectedPermission = UInt16("600", radix: 8)!
        XCTAssertEqual(permission, expectedPermission)

        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
    }

    func testFileProtection() throws {
        #if os(iOS) || os(macOS)
        let fileURL = URL(fileURLWithPath: "./protected.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.protected", fileURL: fileURL, fileProtectionType: .completeUntilFirstUserAuthentication)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("protection, TRACE message using FileLogger")
        log.verbose("protection, VERBOSE message using FileLogger")
        fileLogger.flush(fileURL)

        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        // swiftlint:disable force_cast
        let protection = attributes[FileAttributeKey.protectionKey] as! FileProtectionType
        // swiftlint:enable force_cast

        XCTAssertEqual(protection, FileProtectionType.completeUntilFirstUserAuthentication)

        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
        #endif
    }

    func testExcludeFromBackup() throws {
        #if os(iOS) || os(macOS)
        let fileURL = URL(fileURLWithPath: "./exclude-from-backup.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.exclude-from-backup", fileURL: fileURL, isExcludedFromBackup: true)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("exclude from backup, TRACE message using FileLogger")
        log.verbose("exclude from backup, VERBOSE message using FileLogger")
        fileLogger.flush(fileURL)

        let resourceValues = try fileURL.resourceValues(forKeys: [.isExcludedFromBackupKey])
        XCTAssertTrue(resourceValues.isExcludedFromBackup == true)

        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
        #endif
    }

    func testFilePermissionError() throws {
        let permission800FileURL = URL(fileURLWithPath: "./permission800.log").absoluteURL
        let filePermission800 = "800"
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.permission800", fileURL: permission800FileURL, filePermission: filePermission800)) { error in
            XCTAssertEqual(error as? FileError, .invalidPermission(at: permission800FileURL, filePermission: filePermission800))
            XCTAssertEqual(error.localizedDescription, "invalid file permission. file: \(permission800FileURL), permission: \(filePermission800)")
        }

        let permissionABCFileURL = URL(fileURLWithPath: "./permissionABC.log").absoluteURL
        let filePermissionABC = "ABC"
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.permissionABC", fileURL: permissionABCFileURL, filePermission: filePermissionABC)) { error in
            XCTAssertEqual(error as? FileError, .invalidPermission(at: permissionABCFileURL, filePermission: filePermissionABC))
            XCTAssertEqual(error.localizedDescription, "invalid file permission. file: \(permissionABCFileURL), permission: \(filePermissionABC)")
        }
    }

    func testOpeningToWriteError() throws {
        #if canImport(Darwin)
        let fileURL = URL(fileURLWithPath: "./readonly.log").absoluteURL
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.readonly", fileURL: fileURL, filePermission: "400")) { error in
            XCTAssertEqual(error as? FileError, .openingForWritingFailed(at: fileURL))
            XCTAssertEqual(error.localizedDescription, "failed to open a file for writing: \(fileURL)")
            // swiftlint:disable force_try
            try! FileManager.default.removeItem(at: fileURL)
            // swiftlint:enable force_try
        }
        #endif // canImport(Darwin)
    }

    func testAppendingErrorCatch() throws {
        #if canImport(Darwin)
        let fileURL = URL(fileURLWithPath: "./readonly.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.appendingerrorcatch", fileURL: fileURL)
        var log = Puppy()
        log.add(fileLogger)
        _ = fileLogger.delete(fileURL)
        log.trace("appendingErrorCatch, TRACE message using FileLogger")
        log.remove(fileLogger)
        #endif // canImport(Darwin)
    }

    func testCreatingError() throws {
        #if canImport(Darwin)
        let fileURLNotAbleToCreateDirectory = URL(fileURLWithPath: "/foo/bar.log").absoluteURL  // file:///foo/bar.log
        let directoryURLNotAbleToCreateDirectory = URL(fileURLWithPath: "/foo/").absoluteURL    // file:///foo
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notcreatedirectory",
                                            fileURL: fileURLNotAbleToCreateDirectory)) { error in
            XCTAssertEqual(error as? FileError, .creatingDirectoryFailed(at: directoryURLNotAbleToCreateDirectory))
            XCTAssertEqual(error.localizedDescription, "failed to create a directory: \(directoryURLNotAbleToCreateDirectory)")
        }

        let fileURLNotAbleToCreateFile = URL(fileURLWithPath: "/foo.log").absoluteURL   // file:///foo.log
        XCTAssertThrowsError(try FileLogger("com.example.yourapp.filelogger.notcreatefile",
                                            fileURL: fileURLNotAbleToCreateFile)) { error in
            XCTAssertEqual(error as? FileError, .creatingFileFailed(at: fileURLNotAbleToCreateFile))
            XCTAssertEqual(error.localizedDescription, "failed to create a file: \(fileURLNotAbleToCreateFile)")
        }
        #endif // canImport(Darwin)
    }

    func testDeletingFile() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deleting", fileURL: existentFileURL)

        let resultSuccess = fileLogger.delete(existentFileURL)
        switch resultSuccess {
        case .success(let url):
            XCTAssertEqual(existentFileURL, url)
        case .failure:
            XCTFail("should not be failed, but was failed")
        }

        let resultFailure = fileLogger.delete(noExistentFileURL)
        switch resultFailure {
        case .success:
            XCTFail("should not be successful, but was successful")
        case .failure(let error):
            XCTAssertEqual(error as FileError, .deletingFailed(at: noExistentFileURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
        }
    }

    @available(*, deprecated, message: "Use delete(_:) instead")
    func testDeletingFileAsync() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-async.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-async.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deletingasync", fileURL: existentFileURL)

        let expSuccess = expectation(description: "expSuccessAsyncResult")
        fileLogger.delete(existentFileURL) { result in
            switch result {
            case .success(let url):
                XCTAssertEqual(existentFileURL, url)
                expSuccess.fulfill()
            case .failure:
                XCTFail("should not be failed, but was failed")
            }
        }

        let expFailure = expectation(description: "expFailureAsyncResult")
        fileLogger.delete(noExistentFileURL) { result in
            switch result {
            case .success:
                XCTFail("should not be successful, but was successful")
            case .failure(let error):
                XCTAssertEqual(error as FileError, .deletingFailed(at: noExistentFileURL))
                XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
                expFailure.fulfill()
            }
        }

        wait(for: [expSuccess, expFailure], timeout: 5.0)
    }

    func testDeletingFileResultConversion() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-result-conversion.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-result-conversion.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deletingresultconversion", fileURL: existentFileURL)

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
            XCTAssertEqual(error as FileError, .deletingFailed(at: noExistentFileURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
        }
    }

    @available(*, deprecated, message: "Use delete(_:) instead")
    func testDeletingFileAsyncResultConversion() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-async-result-conversion.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-async-result-conversion.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deletingasyncresultconversion", fileURL: existentFileURL)

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
                XCTAssertEqual(error as? FileError, .deletingFailed(at: noExistentFileURL))
                XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
                expFailure.fulfill()
            }
        }

        wait(for: [expSuccess, expFailure], timeout: 5.0)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testDeletingFileAsyncAwait() async throws {
        #if (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
        let existentFileURL = URL(fileURLWithPath: "./existent-async-await.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-async-await.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deletingasyncawait", fileURL: existentFileURL)

        do {
            let url = try await fileLogger.delete(existentFileURL)
            XCTAssertEqual(url, existentFileURL)
        } catch {
            XCTFail("error should not be thrown, but it was thrown: \(error.localizedDescription)")
        }

        do {
            _ = try await fileLogger.delete(noExistentFileURL)
            XCTFail("error should be thrown while awaiting, but it was not thrown")
        } catch {
            XCTAssertEqual(error as? FileError, .deletingFailed(at: noExistentFileURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
        }
        #endif // (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
    }

    func testFlushFile() throws {
        let fileURL = URL(fileURLWithPath: "./flush.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.flush", fileURL: fileURL, flushMode: .manual)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("flush, TRACE message using FileLogger")
        log.verbose("flush, VERBOSE message using FileLogger")

        fileLogger.flush(fileURL)
        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
    }

    @available(*, deprecated, message: "Use flush(_:) instead")
    func testFlushFileAsync() throws {
        let fileURL = URL(fileURLWithPath: "./flush-async.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.flushasync", fileURL: fileURL, flushMode: .manual)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("flushAsync, TRACE message using FileLogger")
        log.verbose("flushAsync, VERBOSE message using FileLogger")

        let exp = expectation(description: "flushAsync")
        fileLogger.flush(fileURL) {
            // Do NOT add a task into the same queue synchronously.
            // _ = fileLogger.delete(fileURL)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        _ = fileLogger.delete(fileURL)
        log.remove(fileLogger)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testFlushFileAsyncAwait() async throws {
        #if (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
        let fileURL = URL(fileURLWithPath: "./flush-async-await.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.flushasyncawait", fileURL: fileURL, flushMode: .manual)
        var log = Puppy()
        log.add(fileLogger)
        log.trace("flushAsyncAwait, TRACE message using FileLogger")
        log.verbose("flushAsyncAwait, VERBOSE message using FileLogger")

        await fileLogger.flush(fileURL)
        _ = try await fileLogger.delete(fileURL)
        log.remove(fileLogger)
        #endif // (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
    }
}
