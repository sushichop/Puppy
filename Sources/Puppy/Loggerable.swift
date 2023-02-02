import Foundation

public protocol Loggerable: Sendable {
    var label: String { get }
    var logLevel: LogLevel { get }
    var logFormat: LogFormattable? { get }

    func pickMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) async

    func log(_ level: LogLevel, string: String) async
}

extension Loggerable {
    public func pickMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) async {
      let task = Task(priority: .utility) {
            if level.rawValue < logLevel.rawValue {
                return
            }
            var formattedMessage = message
            if let format = logFormat {
                formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
            }
            await log(level, string: formattedMessage)
        }
        await task.value
    }
}
