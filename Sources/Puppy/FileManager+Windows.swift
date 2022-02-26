#if os(Windows)
import Foundation
import WinSDK

extension FileManager {
    func windowsCreationTime(atPath path: String) throws -> TimeInterval {
        let findData = try windowsFindData(atPath: path)
        return TimeInterval(WindowsFileInformation(findData).creationFileTime.seconds)
            + 1.0e-9 * TimeInterval(WindowsFileInformation(findData).creationFileTime.nanoSeconds)
    }

    func windowsModificationTime(atPath path: String) throws -> TimeInterval {
        let findData = try windowsFindData(atPath: path)
        return TimeInterval(WindowsFileInformation(findData).modificationFileTime.seconds)
            + 1.0e-9 * TimeInterval(WindowsFileInformation(findData).modificationFileTime.nanoSeconds)
    }

    func windowsFileSize(atPath path: String) throws -> UInt64 {
        let findData = try windowsFindData(atPath: path)
        return WindowsFileInformation(findData).size
    }
}

func windowsFindData(atPath path: String) throws -> WIN32_FIND_DATAW {
    let binaryStringPath = path.withCString(encodedAs: UTF16.self) { $0 }

    var findData: WIN32_FIND_DATAW = WIN32_FIND_DATAW()
    let handle: HANDLE = FindFirstFileW(binaryStringPath, &findData)
    if handle == INVALID_HANDLE_VALUE {
        throw WindowsFileError.findDataError(atPath: path, code: GetLastError())
    }
    defer { FindClose(handle) }

    return findData
}

public enum WindowsFileError: Error, Equatable, LocalizedError {
    case findDataError(atPath: String, code: UInt32)

    public var errorDescription: String? {
        switch self {
        case .findDataError(atPath: let path, code: let code):
            return "failed to find first file. atPath: \(path), code: \(code)"
        }
    }
}

struct WindowsFileInformation {
    let creationFileTime: WindowsFileTime
    let modificationFileTime: WindowsFileTime
    let size: UInt64

    init(_ findData: WIN32_FIND_DATAW) {
        self.creationFileTime = WindowsFileTime(findData.ftCreationTime)
        self.modificationFileTime = WindowsFileTime(findData.ftLastWriteTime)
        self.size = WindowsFileSize(findData).size
    }
}

struct WindowsFileTime {
    let seconds: UInt64
    let nanoSeconds: UInt64

    private let kSecondsSince1601To1970: UInt64 = 11_644_473_600
    private let kWindowsTickPerSecond: UInt64 = 10_000_000

    init(_ nativeTime: FILETIME) {
        let windowsTicksSince1601 = UInt64(nativeTime.dwHighDateTime) << 32 | UInt64(nativeTime.dwLowDateTime)
        let windowsTicksSince1970 = windowsTicksSince1601 - kWindowsTickPerSecond * kSecondsSince1601To1970
        self.seconds = UInt64(windowsTicksSince1970 / kWindowsTickPerSecond)
        self.nanoSeconds = UInt64(windowsTicksSince1970 % 1_000_000_000)
    }
}

struct WindowsFileSize {
    let size: UInt64

    init(_ findData: WIN32_FIND_DATAW) {
        self.size = UInt64(findData.nFileSizeHigh) << 32 | UInt64(findData.nFileSizeLow)
    }
}

#endif
