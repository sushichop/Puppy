import Foundation
import Puppy

final public class MockLogger: BaseLogger {

    var invokedLog = false
    var invokedLogCount = 0
    var invokedLogLevels: [LogLevel] = []
    var invokedLogStrings: [String] = []

    public override func log(_ level: LogLevel, string: String) {
        invokedLog = true
        invokedLogCount += 1
        invokedLogLevels.append(level)
        invokedLogStrings.append(string)
    }
}

final public class MockLogFormatter: LogFormattable {

    var invokedFormatMessageCount = 0
    var invokedFormatMessageLevels: [LogLevel] = []
    var invokedFormatMessageMessages: [String] = []
    var invokedFormatMessageTags: [String] = []
    var invokedFormatMessageLabel = ""

    public func formatMessage(_ level: LogLevel,
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
        invokedFormatMessageLabel = label
        return "MockLogFormatter \(message)"
    }

}
