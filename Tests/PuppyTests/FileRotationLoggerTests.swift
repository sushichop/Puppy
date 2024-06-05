import XCTest
import Puppy

final class FileRotationLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testFileRotationNumbering() throws {
        let rotationFileURL = URL(fileURLWithPath: "./rotation-numbering/rotation-numbering.log").absoluteURL
        let rotationDirectoryURL = URL(fileURLWithPath: "./rotation-numbering").absoluteURL
        let rotationConfig: RotationConfig = .init(suffixExtension: .numbering, maxFileSize: 512, maxArchivedFilesCount: 4) // // default case
        let delegate: FileRotationDelegate = .init()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.numbering", fileURL: rotationFileURL, rotationConfig: rotationConfig, delegate: delegate)

        var log = Puppy()
        log.add(fileRotation)

        for num in 0...3_000 {
            log.info("\(num) numbering")
        }

        _ = fileRotation.delete(rotationDirectoryURL)
        log.remove(fileRotation)
    }

    func testFileRotationDateUUID() throws {
        let rotationFileURL = URL(fileURLWithPath: "./rotation-date_uuid/rotation-date_uuid.log").absoluteURL
        let rotationDirectoryURL = URL(fileURLWithPath: "./rotation-date_uuid").absoluteURL
        let rotationConfig: RotationConfig = .init(suffixExtension: .date_uuid, maxFileSize: 256, maxArchivedFilesCount: 2)
        let delegate: FileRotationDelegate = .init()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.date_uuid", fileURL: rotationFileURL, rotationConfig: rotationConfig, delegate: delegate)

        var log = Puppy()
        log.add(fileRotation)

        for num in 0...1_000 {
            log.info("\(num) date_uuid")
        }

        _ = fileRotation.delete(rotationDirectoryURL)
        log.remove(fileRotation)
    }

    func testFileRotationErrorCatch() throws {
        let rotationFileURL = URL(fileURLWithPath: "./rotation-error-catch/rotation-error-catch.log").absoluteURL
        let rotationDirectoryURL = URL(fileURLWithPath: "./rotation-error-catch").absoluteURL
        let rotationConfig: RotationConfig = .init()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.errorcatch", fileURL: rotationFileURL, rotationConfig: rotationConfig)

        var log = Puppy()
        log.add(fileRotation)

        _ = fileRotation.delete(rotationDirectoryURL)
        for num in 0...2 {
            log.info("\(num) error-catch")
        }

        let resultFailure = fileRotation.delete(rotationDirectoryURL)
        switch resultFailure {
        case .success:
            XCTFail("should not be successful, but was successful")
        case .failure(let error):
            XCTAssertEqual(error as FileError, .deletingFailed(at: rotationDirectoryURL))
            XCTAssertEqual(error.localizedDescription, "failed to delete a file: \(rotationDirectoryURL)")
        }

        log.remove(fileRotation)
    }

    @available(macOS 13.0, *)
    func testFileRotationArchieveCompression() throws {
        final class CompressorDelegate: FileRotationLoggerDelegate {
            var compressionDelegateWasCalled = false

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
                print("didArchive! didArchiveFileURL: \(didArchiveFileURL), toFileURL: \(toFileURL)")
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
                print("didRemove! didRemoveArchivedFileURL: \(didRemoveArchivedFileURL)")
            }

            func fileRotationLogger(_ fileRotationlogger: FileRotationLogger, didCompressArchivedFileURL: URL, toCompressedFile: URL) {
                compressionDelegateWasCalled = true
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveCompressedFileURL: URL) {
                print("didRemove! didRemoveCompressedFileURL: \(didRemoveCompressedFileURL)")
            }
        }

        let dirPath = NSTemporaryDirectory()
        let logPath = URL(filePath: dirPath + "rotation-compression.log")
        defer {
            try? FileManager.default.removeItem(atPath: dirPath)
        }

        let rotationConfig: RotationConfig = .init(suffixExtension: .numbering, maxFileSize: 512, maxArchivedFilesCount: 4) // // default case
        let delegate: CompressorDelegate = .init()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.numbering", fileURL: logPath, rotationConfig: rotationConfig, delegate: delegate, compressArchived: true)

        var log = Puppy()
        log.add(fileRotation)

        for num in 0...100 {
            log.info("\(num) numbering")
        }

        sleep(5)
        
        XCTAssertTrue(delegate.compressionDelegateWasCalled)

        _ = fileRotation.delete(logPath)
        log.remove(fileRotation)
    }

    @available(macOS 13.0, *)
    func testCompressedArchiveRotation() throws {
        final class RotationDelegate: FileRotationLoggerDelegate {
            var archiveRotationCounter = 0
            var archiveDeleteCounter = 0

            var compressionDelegateWasCalled = false
            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
            }

            func fileRotationLogger(_ fileRotationlogger: FileRotationLogger, didCompressArchivedFileURL: URL, toCompressedFile: URL) {
                archiveRotationCounter += 1
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveCompressedFileURL: URL) {
                archiveDeleteCounter += 1
            }
        }

        let tempPath = NSTemporaryDirectory()
        let logPath = URL(filePath: tempPath + "rotation-compression.log")
        defer {
            try? FileManager.default.removeItem(atPath: tempPath)
        }

        let expectedCompressedCount = UInt8(3)
        var rotationConfig: RotationConfig = .init()
        rotationConfig.maxArchivedFilesCount = expectedCompressedCount
        rotationConfig.maxFileSize = 50
        let delegate = RotationDelegate()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.errorcatch", fileURL: logPath, rotationConfig: rotationConfig, delegate: delegate, compressArchived: true)

        var log = Puppy()
        log.add(fileRotation)

        for num in 0...10 {
            log.info("\(num) very long string")
            sleep(1)
        }

        sleep(3)

        let compressedFiles = try FileManager.default.contentsOfDirectory(atPath: tempPath)
            .map { logPath.deletingLastPathComponent().appendingPathComponent($0) }
            .filter { $0.pathExtension == "archive" }

        XCTAssertEqual(compressedFiles.count, Int(expectedCompressedCount))
        XCTAssertEqual(delegate.archiveRotationCounter-delegate.archiveDeleteCounter, Int(expectedCompressedCount))

        log.remove(fileRotation)
    }

    @available(macOS 13.0, *)
    func testFileRotationWithoutCompression() throws {
        final class RotationDelegate: FileRotationLoggerDelegate {
            var logRotationCounter = 0
            var archiveDeleteCounter = 0

            var compressionDelegateWasCalled = false
            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
                logRotationCounter += 1
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
                archiveDeleteCounter += 1
            }

            func fileRotationLogger(_ fileRotationlogger: FileRotationLogger, didCompressArchivedFileURL: URL, toCompressedFile: URL) {
            }

            func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveCompressedFileURL: URL) {
            }
        }

        let tempPath = NSTemporaryDirectory()
        let logPath = URL(filePath: tempPath + "rotation.log")
        defer {
            try? FileManager.default.removeItem(atPath: tempPath)
        }

        let expectedArchiveCount = UInt8(5)
        var rotationConfig: RotationConfig = .init()
        rotationConfig.maxArchivedFilesCount = expectedArchiveCount
        rotationConfig.maxFileSize = 10
        let delegate = RotationDelegate()
        let fileRotation: FileRotationLogger = try .init("com.example.yourapp.filerotationlogger.errorcatch", fileURL: logPath, rotationConfig: rotationConfig, delegate: delegate, compressArchived: false)

        var log = Puppy()
        log.add(fileRotation)

        for num in 0...10 {
            log.info("\(num) very long string")
        }

        sleep(5)

        let tempDirURL = logPath.deletingLastPathComponent()
        let archives = try FileManager.default.contentsOfDirectory(atPath: tempPath)
            .map { tempDirURL.appendingPathComponent($0) }
            .filter { $0 != logPath && $0.deletingPathExtension() == logPath }

        XCTAssertEqual(archives.count, Int(expectedArchiveCount))
        XCTAssertEqual(delegate.logRotationCounter-delegate.archiveDeleteCounter, Int(expectedArchiveCount))

        log.remove(fileRotation)
    }
}

private final class FileRotationDelegate: FileRotationLoggerDelegate {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
        print("didArchive! didArchiveFileURL: \(didArchiveFileURL), toFileURL: \(toFileURL)")
    }

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
        print("didRemove! didRemoveArchivedFileURL: \(didRemoveArchivedFileURL)")
    }

    func fileRotationLogger(_ fileRotationlogger: FileRotationLogger, didCompressArchivedFileURL: URL, toCompressedFile: URL) {
        print("didCompress! didCompressArchivedFileURL: \(didCompressArchivedFileURL) toCompressedFile: \(toCompressedFile)")
    }

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveCompressedFileURL: URL) {
        print("didRemove! didRemoveCompressedFileURL: \(didRemoveCompressedFileURL)")
    }
}
