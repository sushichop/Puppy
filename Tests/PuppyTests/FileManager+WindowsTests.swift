import XCTest
@testable import Puppy

class FileManagerWindowsTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        Puppy.useDebug = true
    }

    override func tearDownWithError() throws {
        Puppy.useDebug = false
        try super.tearDownWithError()
    }

    func testWindowsCreationTime() throws {
        #if os(Windows)
        let fileURL = URL(fileURLWithPath: "./windows-creation-time.log").absoluteURL
        let successful = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        XCTAssertTrue(successful)

        let creationTime = try FileManager.default.windowsCreationTime(atPath: fileURL.path)
        let creationDateByFileManager = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.creationDate] as! Date // swiftlint:disable:this force_cast

        // NOTE: `attributesOfItem(atPath:)[.creationDate]` has only a second precision information.
        XCTAssertEqual(Int(creationTime), Int(creationDateByFileManager.timeIntervalSince1970))
        try FileManager.default.removeItem(atPath: fileURL.path)
        #endif // os(Windows)
    }

    func testWindowsModificationTime() throws {
        #if os(Windows)
        let fileURL = URL(fileURLWithPath: "./windows-modification-time.log").absoluteURL
        let successful = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        XCTAssertTrue(successful)

        let modificationTime = try FileManager.default.windowsModificationTime(atPath: fileURL.path)
        let modificationDateByFileManager = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.modificationDate] as! Date // swiftlint:disable:this force_cast

        // NOTE: `attributesOfItem(atPath:)[.modificationDate]` has only sub-second precision information.
        XCTAssertEqual(Int(modificationTime), Int(modificationDateByFileManager.timeIntervalSince1970))
        try FileManager.default.removeItem(atPath: fileURL.path)
        #endif // os(Windows)
    }

    func testWindowsFileSize() throws {
        #if os(Windows)
        let fileURL = URL(fileURLWithPath: "./windows-file-size.log").absoluteURL
        let successful = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        XCTAssertTrue(successful)

        let fileSize = try FileManager.default.windowsFileSize(atPath: fileURL.path)
        let fileSizeByFileManager = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as! UInt64 // swiftlint:disable:this force_cast

        XCTAssertEqual(fileSize, fileSizeByFileManager)
        try FileManager.default.removeItem(atPath: fileURL.path)
        #endif // os(Windows)
    }

    func testWindowsFindDataError() throws {
        #if os(Windows)
        // Reference: https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-
        let errorFileNotFound: UInt32 = 2
        let fileURL = URL(fileURLWithPath: "./windows-no-existent.log").absoluteURL

        XCTAssertThrowsError(try windowsFindData(atPath: fileURL.path)) { error in
            XCTAssertEqual(error as? WindowsFileError, .findDataError(atPath: fileURL.path, code: errorFileNotFound))
            XCTAssertEqual(error.localizedDescription, "failed to find first file. atPath: \(fileURL.path), code: \(errorFileNotFound)")
        }
        #endif // os(Windows)
    }
}
