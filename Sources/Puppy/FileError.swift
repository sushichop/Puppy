import Foundation

public typealias Permission = String

public enum FileError: Error, Equatable {
    case isNotFile(url: URL)
    case creatingDirectoryFailed(at: URL)
    case creatingFileFailed(at: URL)
    case writingFailed(at: URL)
    case invalidPermssion(_ filePermission: Permission)
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
