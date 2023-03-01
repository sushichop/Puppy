import Foundation

public protocol Loggerable: Sendable {
    var label: String { get }
    var queue: DispatchQueue { get }
    var logLevel: LogLevel { get }
    var logFormat: LogFormattable? { get }

    func pickMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64)

    func log(_ level: LogLevel, string: String)

    func flush(completion: @escaping @Sendable () -> Void)
}

extension Loggerable {
    public func pickMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) {
        queue.async {
            if level.rawValue < logLevel.rawValue {
                return
            }
            var formattedMessage = message
            if let format = logFormat {
                formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
            }
            log(level, string: formattedMessage)
        }
    }

    public func flush(completion: @escaping @Sendable () -> Void) {
        queue.async {
            completion()
        }
    }
}
