import Foundation

public class FileLogger: BaseLogger {

    public private(set) var flushMode: FlushMode

    var fileHandle: FileHandle!
    let fileURL: URL

    public init(_ label: String, fileURL: URL, flushMode: FlushMode = .always) throws {
        self.fileURL = fileURL
        self.flushMode = flushMode
        debug("fileURL is \(fileURL).")
        super.init(label)
        try validateFileURL(fileURL)
        try openFile()
    }

    deinit {
        closeFile()
    }

    public override func log(_ level: LogLevel, string: String) {
        do {
            _ = try fileHandle?.seekToEndCompatible()
            if let data = (string + "\r\n").data(using: .utf8) {
                // swiftlint:disable force_try
                try! fileHandle?.writeCompatible(contentsOf: data)
                // swiftlint:enable force_try
                if flushMode == .always {
                    fileHandle?.synchronizeFile()
                }
            }
        } catch {
            print("seekToEnd error. error is \(error.localizedDescription).")
        }
    }

    public func delete(_ url: URL) -> Result<URL, FileDeletingError> {
        queue!.sync {
            Result { try FileManager.default.removeItem(at: url) }
                .map { url }
                .mapError { _ in
                    FileDeletingError.failed(at: url)
                }
        }
    }

    public func delete(_ url: URL, completion: @escaping (Result<URL, FileDeletingError>) -> Void) {
        queue!.async {
            let result = Result { try FileManager.default.removeItem(at: url) }
                .map { url }
                .mapError { _ in
                    FileDeletingError.failed(at: url)
                }
            completion(result)
        }
    }

    #if compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func delete(_ url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            queue!.async {
                do {
                    try FileManager.default.removeItem(at: url)
                    continuation.resume(returning: url)
                } catch {
                    continuation.resume(throwing: FileDeletingError.failed(at: url))
                }
            }
        }
    }
    #endif

    public func flush() {
        queue!.sync {
            fileHandle?.synchronizeFile()
        }
    }

    public func flush(completion: @escaping () -> Void) {
        queue!.async {
            completion()
        }
    }

    #if compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func flush() async {
        await withCheckedContinuation { continuation in
            queue!.async {
                continuation.resume()
            }
        }
    }
    #endif

    func openFile() throws {
        closeFile()
        let directoryURL = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            debug("created directoryURL is \(directoryURL).")
        } catch {
            throw FileError.creatingDirectoryFailed(at: directoryURL)
        }

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let successful = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            if successful {
                debug("succeeded in creating filePath.")
            } else {
                throw FileError.creatingFileFailed(at: fileURL)
            }
        } else {
            debug("filePath exists. filePath is \(fileURL.path).")
        }

        if fileHandle == nil {
            do {
                fileHandle = try FileHandle(forWritingTo: fileURL)
            } catch {
                throw FileError.writingFailed(at: fileURL)
            }
        }
    }

    func closeFile() {
        if fileHandle != nil {
            fileHandle.synchronizeFile()
            fileHandle.closeFile()
            fileHandle = nil
        }
    }

    private func validateFileURL(_ url: URL) throws {
        if url.hasDirectoryPath {
            throw FileError.isNotFile(url: url)
        }
    }
}

public enum FlushMode {
    case always
    case manual
}

extension FileHandle {
    func seekToEndCompatible() throws -> UInt64 {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            return try seekToEnd()
        } else {
            return seekToEndOfFile()
        }
    }

    func writeCompatible(contentsOf data: Data) throws {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            try write(contentsOf: data)
        } else {
            write(data)
        }
    }
}
