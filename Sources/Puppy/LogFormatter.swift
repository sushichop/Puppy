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

/// Returns the string representation of the provided `date` formatted by the passed `formatter`.
///
///  By passing a pre initialized `DateFormatter`, **dateFormatter** function call stays performant.
@Sendable
public func dateFormatter(_ date: Date, withFormatter dateFormatter: DateFormatter) -> String {
    return dateFormatter.string(from: date)
}

/// Returns the string representation of the provided `date` formatted by the passed `formatter`. The `formatter` can be further customized by `locale`, `dateFormat` and `timeZone` parameters.
///
/// Even when setting the formatter parameters, by passing a pre initialized `DateFormatter`, **dateFormatter** function stays relatively efficient.
@Sendable
public func dateFormatter(_ date: Date, withFormatter dateFormatter: DateFormatter, locale: String = "en_US_POSIX", dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", timeZone: String = "") -> String {
    dateFormatter.locale = Locale(identifier: locale)
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(identifier: timeZone)
    return dateFormatter.string(from: date)
}
