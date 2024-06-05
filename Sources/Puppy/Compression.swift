//
//  compression.swift
//  Puppy
//
//  Created by Nagy Peter on 05/06/2024.
//

import Foundation
import AppleArchive
import System

class Compressor {
    enum CompressionError: Error, Equatable, LocalizedError {
        case createFileStream(stream: String)
        case archive(filename: String, err: String)

        public var errorDescription: String? {
            switch self {
            case.createFileStream(stream: let stream):
                return "unable to create \(stream) stream"
            case .archive(filename: let file, err: let error):
                return "unable to archieve \(file): \(error)"
            }
        }
    }

    static func uniqueName(file: String) -> String {
        return "\(file).\(ProcessInfo().hostName).\(Int(Date().timeIntervalSince1970)).archive"
    }

    static func lzfse(src: String, dst: String) throws {
        if #available(macOS 11.0, *) {
            let sourcePath = FilePath(src)
            let destinationPath = FilePath(dst)

            guard let readFileStream = ArchiveByteStream.fileStream(
                    path: sourcePath,
                    mode: .readOnly,
                    options: [ ],
                    permissions: FilePermissions(rawValue: 0o644)) else {
                throw CompressionError.createFileStream(stream: "read")
            }
            defer {
                try? readFileStream.close()
            }
            
            guard let writeFileStream = ArchiveByteStream.fileStream(
                    path: destinationPath,
                    mode: .writeOnly,
                    options: [ .create ],
                    permissions: FilePermissions(rawValue: 0o644)) else {
                throw CompressionError.createFileStream(stream: "write")
            }
            defer {
                try? writeFileStream.close()
            }

            guard let compressStream = ArchiveByteStream.compressionStream(
                    using: .lzfse,
                    writingTo: writeFileStream) else {
                throw CompressionError.createFileStream(stream: "compress")
            }
            defer {
                try? compressStream.close()
            }

            do {
                _ = try ArchiveByteStream.process(readingFrom: readFileStream,
                                                  writingTo: compressStream)
            } catch {
                throw CompressionError.archive(filename: src, err: error.localizedDescription)
            }
        } else {
            puppyDebug("lzfse compression is not supported on this macOS version")
        }
    }
}
