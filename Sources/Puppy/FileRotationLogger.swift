import Foundation

public class FileRotationLogger: FileLogger {

    public enum SuffixExtension {
        case numbering
        // swiftlint:disable identifier_name
        case date_uuid
        // swiftlint:enable identifier_name
    }
    public var suffixExtension: SuffixExtension = .date_uuid

    public typealias ByteCount = UInt64
    public var maxFileSize: ByteCount = 10 * 1024 * 1024
    public var maxArchivedFilesCount: UInt8 = 5

    public weak var delegate: FileRotationLoggerDelegate?

    public init(_ label: String, fileURL: URL, filePermssion: Permission = "640") throws {
        try super.init(label, fileURL: fileURL, filePermisson: filePermssion)
    }

    public override func log(_ level: LogLevel, string: String) {
        rotateFiles()
        super.log(level, string: string)
        rotateFiles()
    }

    private func rotateFiles() {
        guard let size = try? fileHandle.seekToEndCompatible(), size > maxFileSize else { return }
        closeFile()

        // Rotates old archived files.
        switch suffixExtension {
        case .numbering:
            do {
                let oldArchivedFileURLs = ascArchivedFileURLs(fileURL)
                for (index, oldArchivedFileURL) in oldArchivedFileURLs.enumerated() {
                    let generationNumber = oldArchivedFileURLs.count + 1 - index
                    let rotatedFileURL = oldArchivedFileURL.deletingPathExtension().appendingPathExtension("\(generationNumber)")
                    debug("generationNumber: \(generationNumber), rotatedFileURL: \(rotatedFileURL)")
                    if !FileManager.default.fileExists(atPath: rotatedFileURL.path) {
                        try FileManager.default.moveItem(at: oldArchivedFileURL, to: rotatedFileURL)
                    }
                }
            } catch {
                print("error in rotating old archive files, error: \(error.localizedDescription)")
            }
        case .date_uuid:
            break
        }

        // Archives the target file.
        do {
            var archivedFileURL: URL
            switch suffixExtension {
            case .numbering:
                archivedFileURL = fileURL.appendingPathExtension("1")
            case .date_uuid:
                archivedFileURL = fileURL.appendingPathExtension(dateFormatter(Date(), dateFormat: "yyyyMMdd'T'HHmmssZZZZZ", timeZone: "UTC") + "_" + UUID().uuidString.lowercased())
            }
            try FileManager.default.moveItem(at: fileURL, to: archivedFileURL)
            delegate?.fileRotationLogger(self, didArchiveFileURL: fileURL, toFileURL: archivedFileURL)
        } catch {
            print("error in archiving the target file, error: \(error.localizedDescription)")
        }

        // Removes extra archived files.
        removeArchivedFiles(fileURL, maxArchivedFilesCount: maxArchivedFilesCount)

        // Opens a new target file.
        do {
            debug("will openFile in rotateFiles")
            try openFile()
        } catch {
            print("error in openFile while rotating, error: \(error.localizedDescription)")
        }
    }

    private func ascArchivedFileURLs(_ fileURL: URL) -> [URL] {
        var ascArchivedFileURLs: [URL] = []
        do {
            let archivedDirectoryURL = fileURL.deletingLastPathComponent()
            let archivedFileURLs = try FileManager.default
                .contentsOfDirectory(at: archivedDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                .filter { $0 != fileURL && $0.deletingPathExtension() == fileURL }
            ascArchivedFileURLs = try archivedFileURLs.sorted {
                let modificationDate0 = try FileManager.default.attributesOfItem(atPath: $0.path)[.modificationDate] as? Date
                let modificationDate1 = try FileManager.default.attributesOfItem(atPath: $1.path)[.modificationDate] as? Date
                return modificationDate0!.timeIntervalSince1970 < modificationDate1!.timeIntervalSince1970
            }
        } catch {
            print("error in ascArchivedFileURLs, error: \(error.localizedDescription)")
        }
        debug("ascArchivedFileURLs: \(ascArchivedFileURLs)")
        return ascArchivedFileURLs
    }

    private func removeArchivedFiles(_ fileURL: URL, maxArchivedFilesCount: UInt8) {
        do {
            let archivedFileURLs = ascArchivedFileURLs(fileURL)
            if archivedFileURLs.count > maxArchivedFilesCount {
                for index in 0 ..< archivedFileURLs.count - Int(maxArchivedFilesCount) {
                    debug("\(archivedFileURLs[index]) will be removed...")
                    try FileManager.default.removeItem(at: archivedFileURLs[index])
                    debug("\(archivedFileURLs[index]) has been removed")
                    delegate?.fileRotationLogger(self, didRemoveArchivedFileURL: archivedFileURLs[index])
                }
            }
        } catch {
            print("error in removing extra archived files, error: \(error.localizedDescription)")
        }
    }
}

public protocol FileRotationLoggerDelegate: AnyObject {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL)
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL)
}
