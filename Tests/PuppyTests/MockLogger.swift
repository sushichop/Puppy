import Foundation
import Puppy

final class MockLogger: Loggerable, @unchecked Sendable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    var invokedLog = false
    var invokedLogCount = 0
    var invokedLogLevels: [LogLevel] = []
    var invokedLogStrings: [String] = []

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil) {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
    }

    public func log(_ level: LogLevel, string: String) {
        invokedLog = true
        invokedLogCount += 1
        invokedLogLevels.append(level)
        invokedLogStrings.append(string)
    }
}

final class MockLogFormatter: LogFormattable, @unchecked Sendable {
    var invokedFormatMessageCount = 0
    var invokedFormatMessageLevels: [LogLevel] = []
    var invokedFormatMessageMessages: [String] = []
    var invokedFormatMessageTags: [String] = []
    var invokedFormatMessageSwiftLogInfo: [String: String] = [:]
    var invokedFormatMessageLabel = ""

    func formatMessage(_ level: LogLevel,
                       message: String,
                       tag: String,
                       function: String,
                       file: String,
                       line: UInt,
                       swiftLogInfo: [String: String],
                       label: String,
                       date: Date,
                       threadID: UInt64) -> String {
        invokedFormatMessageCount += 1
        invokedFormatMessageLevels.append(level)
        invokedFormatMessageMessages.append(message)
        invokedFormatMessageTags.append(tag)
        invokedFormatMessageSwiftLogInfo = swiftLogInfo
        invokedFormatMessageLabel = label
        return "MockLogFormatter \(message)"
    }
}
