import Foundation

public class ConsoleLogger: BaseLogger {

    public override func log(_ level: LogLevel, string: String) {
        print(string)
    }
}
