import Foundation

public enum FileError: Error, Equatable {
    case isNotFile(url: URL)
    case creatingDirectoryFailed(at: URL)
    case creatingFileFailed(at: URL)
    case writingFailed(at: URL)
    case deletingFailed(at: URL)
}
