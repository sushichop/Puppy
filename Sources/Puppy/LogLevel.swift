import Foundation

public enum LogLevel: UInt8 {
    case trace      = 1
    case verbose    = 2
    case debug      = 3
    case info       = 4
    case notice     = 5
    case warning    = 6
    case error      = 7
    case critical   = 8
}

extension LogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .trace:
            return "TRACE"      // 🟤   // darkGray
        case .verbose:
            return "VERBOSE"    // 🟣   // lightMagenta
        case.debug:
            return "DEBUG"      // 🔵   // lightBlue
        case .info:
            return "INFO"       // 🟢   // lightGreen
        case .notice:
            return "NOTICE"     // 🟠   // yellow
        case .warning:
            return "WARNING"    // 🟡   // lightYellow
        case .error:
            return "ERROR"      // 🔴   // lightRed
        case .critical:
            return "CRITICAL"   // 💥   // red
        }
    }
}

extension LogLevel {
    var emoji: String {
        switch self {
        case .trace:
            return "🟤"
        case .verbose:
            return "🟣"
        case .debug:
            return "🔵"
        case .info:
            return "🟢"
        case .notice:
            return "🟠"
        case .warning:
            return "🟡"
        case .error:
            return "🔴"
        case .critical:
            return "💥"
        }
    }

    var color: LogColor {
        switch self {
        case .trace:
            return .darkGray
        case .verbose:
            return .lightMagenta
        case .debug:
            return .lightBlue
        case .info:
            return .lightGreen
        case .notice:
            return .yellow
        case .warning:
            return .lightYellow
        case .error:
            return .lightRed
        case .critical:
            return .red
        }
    }
}
