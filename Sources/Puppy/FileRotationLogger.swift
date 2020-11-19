import Foundation

public class FileRotationLogger: BaseLogger {

    public override var queue: DispatchQueue! {
        return Self.fileRotationLoggerQueue
    }

    private static let fileRotationLoggerQueue = DispatchQueue(label: "net.sushichop.puppy.filerotationlogger")

    public typealias ByteCount = UInt64
    public var maxFileSize: ByteCount = 10 * 1024 * 1024
    public var maxArchivedFilesCount: UInt8 = 5

    private var fileHandle: FileHandle!
    private let fileURL: URL

    public weak var delegate: FileRotationLoggerDeletate?

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
        rotateFiles()

        do {
            _ = try fileHandle?.seekToEndCompatible()
            if let data = (string + "\r\n").data(using: .utf8) {
                // swiftlint:disable force_try
                try! fileHandle?.writeCompatible(contentsOf: data)
                // swiftlint:enable force_try
            }
        } catch {
            print("seekToEnd error. error is \(error.localizedDescription).")
        }

        rotateFiles()
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

    private func rotateFiles() {
        if let size = try? fileHandle.seekToEndCompatible(), size > maxFileSize {
            closeFile()
            do {
                let archivedFileURL = fileURL.deletingPathExtension()
                    .appendingPathExtension(dateFormatter(Date()) + "_" + UUID().uuidString.lowercased())
                try FileManager.default.moveItem(at: fileURL, to: archivedFileURL)
                delegate?.fileRotationLogger(self, didArchiveFileURL: fileURL, toFileURL: archivedFileURL)
            } catch {
                print("moving error. error.localizedDescription is \(error.localizedDescription).")
            }

            // Removes old archived file
            let archivedDirectoryURL = fileURL.deletingLastPathComponent()
            do {
                let archivedFileURLs = try FileManager.default
                    .contentsOfDirectory(at: archivedDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    .filter { $0 != fileURL }

                if archivedFileURLs.count > maxArchivedFilesCount {
                    let sortedArchivedFileURLs = try archivedFileURLs.sorted {
                        let creationDate0 = try FileManager.default.attributesOfItem(atPath: $0.path)[.modificationDate] as? Date
                        let creationDate1 = try FileManager.default.attributesOfItem(atPath: $1.path)[.modificationDate] as? Date
                        return creationDate0!.timeIntervalSince1970 < creationDate1!.timeIntervalSince1970
                    }
                    debug("sortedArchivedFileURLs is \(sortedArchivedFileURLs).")
                    for index in 0 ..< archivedFileURLs.count - Int(maxArchivedFilesCount) {
                        debug("\(sortedArchivedFileURLs[index]) will be removed...")
                        try FileManager.default.removeItem(at: sortedArchivedFileURLs[index])
                        debug("\(sortedArchivedFileURLs[index]) has been removed.")
                        delegate?.fileRotationLogger(self, didRemoveArchivedFileURL: sortedArchivedFileURLs[index])
                    }
                }
            } catch {
                print("archivedFileURLs error. error is \(error.localizedDescription).")
            }

            do {
                debug("will openFile in rotateFiles.")
                try openFile()
            } catch {
                print("openFile error in rotating. error is \(error.localizedDescription).")
            }

        }

    }
}

public protocol FileRotationLoggerDeletate: class {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL)
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL)
}
