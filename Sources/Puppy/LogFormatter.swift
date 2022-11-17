import Foundation

public protocol LogFormattable: Sendable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String
}

extension LogFormattable {
    public func moduleName(_ file: String) -> String {
        return file.components(separatedBy: "/").first!
    }

    public func fileName(_ file: String) -> String {
        return file.components(separatedBy: "/").last!
    }
}

@Sendable
public func dateFormatter(_ date: Date, locale: String = "en_US_POSIX", dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", timeZone: String = "") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: locale)
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(identifier: timeZone)
    return dateFormatter.string(from: date)
}
