import Foundation

public class FileRotationLogger: FileLogger {

    public typealias ByteCount = UInt64
    public var maxFileSize: ByteCount = 10 * 1024 * 1024
    public var maxArchivedFilesCount: UInt8 = 5

    public weak var delegate: FileRotationLoggerDeletate?

    public init(_ label: String, fileURL: URL) throws {
        try super.init(label, fileURL: fileURL)
    }

    public override func log(_ level: LogLevel, string: String) {
        rotateFiles()
        super.log(level, string: string)
        rotateFiles()
    }

    private func rotateFiles() {
        if let size = try? fileHandle.seekToEndCompatible(), size > maxFileSize {
            closeFile()
            do {
                let archivedFileURL = fileURL.deletingPathExtension()
                    .appendingPathExtension(dateFormatter(Date(), dateFormat: "yyyyMMdd'T'HHmmss.SSSZZZZZ", timeZone: "GMT") + "_" + UUID().uuidString.lowercased())
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

public protocol FileRotationLoggerDeletate: AnyObject {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL)
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL)
}
