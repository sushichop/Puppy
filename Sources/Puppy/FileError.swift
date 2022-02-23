import Foundation

public enum FileError: Error, Equatable {
    case isNotFile(url: URL)
    case creatingDirectoryFailed(at: URL)
    case creatingFileFailed(at: URL)
    case writingFailed(at: URL)
    case invalidPermission(at: URL, filePermission: String)
}

public enum FileDeletingError: Error, Equatable, LocalizedError {
    case failed(at: URL)

    public var errorDescription: String? {
        switch self {
        case .failed(at: let url):
            return "failed to delete the file: \(url)"
        }
    }
}
