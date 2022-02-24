import Foundation

public enum FileError: Error, Equatable, LocalizedError {
    case isNotFile(url: URL)
    case invalidPermission(at: URL, filePermission: String)
    case creatingDirectoryFailed(at: URL)
    case creatingFileFailed(at: URL)
    case openingForWritingFailed(at: URL)
    case deletingFailed(at: URL)

    public var errorDescription: String? {
        switch self {
        case .isNotFile(url: let url):
            return "\(url) is not a file"
        case .invalidPermission(at: let url, filePermission: let filePermission):
            return "invalid file permission. file: \(url), permission: \(filePermission)"
        case .creatingDirectoryFailed(at: let url):
            return "failed to create a directory: \(url)"
        case .creatingFileFailed(at: let url):
            return "failed to create a file: \(url)"
        case .openingForWritingFailed(at: let url):
            return "failed to open a file for writing: \(url)"
        case .deletingFailed(at: let url):
            return "failed to delete a file: \(url)"
        }
    }
}
