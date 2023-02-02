import XCTest
import Puppy

final class FileLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testFileLogger() async throws {
        let fileURL = URL(fileURLWithPath: "./foo/bar.log").absoluteURL
        let directoryURL = URL(fileURLWithPath: "./foo").absoluteURL

        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger", fileURL: fileURL)
        var log = Puppy()
        log.add(fileLogger)
        await log.trace("\(Date()): TRACE message using FileLogger")
        await log.verbose("\(Date()): VERBOSE message using FileLogger")

        _ = try await fileLogger.delete(directoryURL)
        log.remove(fileLogger)
    }

    func testTildeFileLogger() async throws {
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
        await log.trace("Tilde, TRACE message using FileLogger")
        await log.verbose("Tilde, VERBOSE message using FileLogger")

        _ = try await fileLogger.delete(directoryURL)
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

    func testFilePermission() async throws {
        let fileURL = URL(fileURLWithPath: "./permission600.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.permission600", fileURL: fileURL, filePermission: "600")
        var log = Puppy()
        log.add(fileLogger)
        await log.trace("permission, TRACE message using FileLogger")
        await log.verbose("permission, VERBOSE message using FileLogger")
        await fileLogger.flush(fileURL)

        let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        // swiftlint:disable force_cast
        let permission = attribute[FileAttributeKey.posixPermissions] as! UInt16
        // swiftlint:enable force_cast

        #if os(Windows)
        // NOTE: If the file is writable, its permission is always "700" on Windows.
        // Reference: https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/FileManager%2BWin32.swift
        let expectedPermission = UInt16("700", radix: 8)!
        #else
        let expectedPermission = UInt16("600", radix: 8)!
        #endif // os(Windows)
        XCTAssertEqual(permission, expectedPermission)

        _ = try await fileLogger.delete(fileURL)
        log.remove(fileLogger)
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

    func testAppendingErrorCatch() async throws {
        #if canImport(Darwin)
        let fileURL = URL(fileURLWithPath: "./readonly.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.appendingerrorcatch", fileURL: fileURL)
        var log = Puppy()
        log.add(fileLogger)
        _ = try await fileLogger.delete(fileURL)
        await log.trace("appendingErrorCatch, TRACE message using FileLogger")
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

    func testDeletingFile() async throws {
        let existentFileURL = URL(fileURLWithPath: "./existent.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deleting", fileURL: existentFileURL)

        let url = try await fileLogger.delete(existentFileURL)
        XCTAssertEqual(existentFileURL, url)

        do {
            _ = try await fileLogger.delete(noExistentFileURL)
            XCTFail("should not be successful, but was successful")
        } catch let error as FileError {
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
        }
    }

    func testDeletingFileResultConversion() async throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-result-conversion.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-result-conversion.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.deletingresultconversion", fileURL: existentFileURL)

        do {
            let url = try await fileLogger.delete(existentFileURL)
            XCTAssertEqual(url, existentFileURL)
        } catch {
            XCTFail("error should not be thrown, but it was thrown: \(error.localizedDescription)")
        }

        do {
            _ = try await fileLogger.delete(noExistentFileURL)
            XCTFail("error should be thrown while awaiting, but it was not thrown")
        } catch let error as FileError {
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(noExistentFileURL)")
        }
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

    func testFlushFile() async throws {
        let fileURL = URL(fileURLWithPath: "./flush.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.flush", fileURL: fileURL, flushMode: .manual)
        var log = Puppy()
        log.add(fileLogger)
        await log.trace("flush, TRACE message using FileLogger")
        await log.verbose("flush, VERBOSE message using FileLogger")

        await fileLogger.flush(fileURL)
        _ = try await fileLogger.delete(fileURL)
        log.remove(fileLogger)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testFlushFileAsyncAwait() async throws {
        #if (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
        let fileURL = URL(fileURLWithPath: "./flush-async-await.log").absoluteURL
        let fileLogger: FileLogger = try .init("com.example.yourapp.filelogger.flushasyncawait", fileURL: fileURL, flushMode: .manual)
        var log = Puppy()
        log.add(fileLogger)
        await log.trace("flushAsyncAwait, TRACE message using FileLogger")
        await log.verbose("flushAsyncAwait, VERBOSE message using FileLogger")

        await fileLogger.flush(fileURL)
        _ = try await fileLogger.delete(fileURL)
        log.remove(fileLogger)
        #endif // (compiler(>=5.5.2) && !os(Windows)) || compiler(>=5.7)
    }
}
