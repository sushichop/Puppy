import Foundation

public class FileLogger: BaseLogger {

    public override var queue: DispatchQueue! {
        return Self.fileLoggerQueue
    }

    private static let fileLoggerQueue = DispatchQueue(label: "net.sushichop.puppy.filelogger")

    public var flushmode: FlushMode = .always

    private var fileHandle: FileHandle!
    private let fileURL: URL

    public init(_ label: String, fileURL: URL) throws {
        self.fileURL = fileURL
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
                if flushmode == .always {
                    fileHandle?.synchronizeFile()
                }
            }
        } catch {
            print("seekToEnd error. error is \(error.localizedDescription).")
        }
    }

    public func delete(_ url: URL) throws {
        do {
            try queue.sync {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            throw FileError.deletingFailed(at: url)
        }
    }

    public func flush() {
        queue.sync {
            fileHandle?.synchronizeFile()
        }
    }

    private func validateFileURL(_ url: URL) throws {
        if url.hasDirectoryPath {
            throw FileError.isNotFile(url: url)
        }
    }

    private func openFile() throws {
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

    private func closeFile() {
        if fileHandle != nil {
            fileHandle.synchronizeFile()
            fileHandle.closeFile()
            fileHandle = nil
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
