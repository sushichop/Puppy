import XCTest
@testable import Puppy

final class FileRotationLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        Puppy.useDebug = true
    }

    override func tearDownWithError() throws {
        Puppy.useDebug = false
        try super.tearDownWithError()
    }

    func testFileRotationLogger() throws {
        let rotationFileURL = URL(fileURLWithPath: "./rotation/rotation-foo.log").absoluteURL
        let rotationDirectoryURL = URL(fileURLWithPath: "./rotation").absoluteURL

        let fileRotation = try FileRotationLogger("com.example.yourapp.filerotationlogger", fileURL: rotationFileURL)
        fileRotation.maxFileSize = 256
        fileRotation.maxArchivedFilesCount = 2
        fileRotation.delegate = self

        let log = Puppy()
        log.add(fileRotation)

        for num in 0...1_000 {
            log.info("\(num) message")
        }

        try fileRotation.delete(rotationDirectoryURL)
        log.remove(fileRotation)
    }
}

extension FileRotationLoggerTests: FileRotationLoggerDeletate {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL) {
        print("didArchive! didArchiveFileURL is \(didArchiveFileURL). toFileURL is \(toFileURL).")
    }

    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL) {
        print("didRemove! didRemoveArchivedFileURL is \(didRemoveArchivedFileURL).")
    }
}
