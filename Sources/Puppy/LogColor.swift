import Foundation

/// LogColor
///
/// Reference:
/// [ANSI escape code](https://en.wikipedia.org/wiki/ANSI_escape_code)
/// [256 COLORS - CHEAT SHEET](https://jonasjacek.github.io/colors/)
public enum LogColor: Sendable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case lightGray

    case darkGray
    case lightRed
    case lightGreen
    case lightYellow
    case lightBlue
    case lightMagenta
    case lightCyan
    case white

    case colorNumber(_ number: UInt8)

    public var resetCode: String { return "\u{001B}[0m" }

    public var foregroundCode: String {
        switch self {
        case .black:
            return "\u{001B}[30m"
        case .red:
            return "\u{001B}[31m"
        case .green:
            return "\u{001B}[32m"
        case .yellow:
            return "\u{001B}[33m"
        case .blue:
            return "\u{001B}[34m"
        case .magenta:
            return "\u{001B}[35m"
        case .cyan:
            return "\u{001B}[36m"
        case .lightGray:
            return "\u{001B}[37m"

        case .darkGray:
            return "\u{001B}[90m"
        case .lightRed:
            return "\u{001B}[91m"
        case .lightGreen:
            return "\u{001B}[92m"
        case .lightYellow:
            return "\u{001B}[93m"
        case .lightBlue:
            return "\u{001B}[94m"
        case .lightMagenta:
            return "\u{001B}[95m"
        case .lightCyan:
            return "\u{001B}[96m"
        case .white:
            return "\u{001B}[97m"

        case .colorNumber(let number):
            return "\u{001B}[38;5;\(number)m"
        }
    }
}

extension String {
    @Sendable
    public func colorize(_ color: LogColor) -> String {
        return color.foregroundCode + self + color.resetCode
    }
}
