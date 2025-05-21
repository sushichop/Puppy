import XCTest
import Puppy

final class FileRotationLoggerTests: XCTestCase {

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
}

private final class FileRotationDelegate: FileRotationLoggerDelegate {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
        print("didArchive! didArchiveFileURL: \(didArchiveFileURL), toFileURL: \(toFileURL)")
    }

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
        print("didRemove! didRemoveArchivedFileURL: \(didRemoveArchivedFileURL)")
    }
}
