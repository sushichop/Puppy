import XCTest
@testable import Puppy

class FileRotationLoggerTests: XCTestCase, FileRotationLoggerDeletate {

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
        print("didArchive! didArchiveFileURL is \(didArchiveFileURL). toFileURL is \(toFileURL).")
    }

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
        print("didRemove! didRemoveArchivedFileURL is \(didRemoveArchivedFileURL).")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        Puppy.useDebug = true
    }

    override func tearDownWithError() throws {
        Puppy.useDebug = false
        try super.tearDownWithError()
    }

    func testFileRotationLogger() throws {
        let rotationFileURL = URL(fileURLWithPath: "./rotation/hoge.log").absoluteURL
        let fileRotation = try FileRotationLogger("com.example.yourapp.filerotationlogger", fileURL: rotationFileURL)

        fileRotation.maxFileSize = 256
        fileRotation.maxArchivedFilesCount = 2
        fileRotation.delegate = self

        let log = Puppy()
        log.add(fileRotation)

        for num in 0...1_000 {
            log.info("\(num) message")
        }

        let rotationDirectoryURL = URL(fileURLWithPath: "./rotation").absoluteURL
        try fileRotation.delete(rotationDirectoryURL)
        log.remove(fileRotation)
    }

    func testCheckFileType() throws {
        let emptyFileURL = URL(fileURLWithPath: "").absoluteURL     // file:///private/tmp/
        XCTAssertThrowsError(try FileRotationLogger("com.example.yourapp.filerotationlogger.notfile0",
                                                    fileURL: emptyFileURL)) { error in
            let error = error as? FileError
            XCTAssertEqual(error, FileError.isNotFile(url: emptyFileURL))
        }

        let directoryURL = URL(fileURLWithPath: "./").absoluteURL   // file:///private/tmp/
        XCTAssertThrowsError(try FileRotationLogger("com.example.yourapp.filerotationlogger.notfile1",
                                                    fileURL: directoryURL)) { error in
            let error = error as? FileError
            XCTAssertEqual(error, FileError.isNotFile(url: directoryURL))
        }
    }

    #if os(macOS)
    func testCreatingError() throws {
        let fileURLNotAbleToCreateDirectory = URL(fileURLWithPath: "../../foo-rotation/bar-rotation.log").absoluteURL // file:///foo-rotation/bar-rotation.log
        let directoryURLNotAbleToCreateDirectory = URL(fileURLWithPath: "../../").absoluteURL
            .appendingPathComponent("foo-rotation", isDirectory: true)   // file:///file/foo-rotation/
        XCTAssertThrowsError(try FileRotationLogger("com.example.yourapp.filerotationlogger.notcreatedirectory",
                                                    fileURL: fileURLNotAbleToCreateDirectory)) { error in
            let error = error as? FileError
            XCTAssertEqual(error, FileError.creatingDirectoryFailed(at: directoryURLNotAbleToCreateDirectory))
        }

        let fileURLNotAbleToCreateFile = URL(fileURLWithPath: "../foo-rotation.log").absoluteURL     // file:///private/foo-rotation.log
        XCTAssertThrowsError(try FileRotationLogger("com.example.yourapp.filerotationlogger.notcreatefile",
                                                    fileURL: fileURLNotAbleToCreateFile)) { error in
            let error = error as? FileError
            XCTAssertEqual(error, FileError.creatingFileFailed(at: fileURLNotAbleToCreateFile))
        }
    }
    #endif

    func testDeletingFile() throws {
        let existentFileURL = URL(fileURLWithPath: "./existent-rotation.log").absoluteURL
        let noExistentFileURL = URL(fileURLWithPath: "./no-existent-rotation.log").absoluteURL

        let fileLoggerError = try FileRotationLogger("com.example.yourapp.filerotationlogger.error",
                                                     fileURL: existentFileURL)
        try fileLoggerError.delete(existentFileURL)

        XCTAssertThrowsError(try fileLoggerError.delete(noExistentFileURL)) { error in
            let error = error as? FileError
            XCTAssertEqual(error, FileError.deletingFailed(at: noExistentFileURL))
        }
    }
}
