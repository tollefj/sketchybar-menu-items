public enum Command: Equatable, Sendable {
    case list(ignore: [String])
    case press(String)
    case trust
    case help
    case version

    public init(arguments: [String]) throws {
        switch arguments.first {
        case "list":
            self = .list(ignore: try Self.ignorePatterns(Array(arguments.dropFirst())))
        case "press" where arguments.count == 2:
            self = .press(arguments[1])
        case "trust" where arguments.count == 1:
            self = .trust
        case "help", "-h", "--help":
            self = .help
        case "version", "--version":
            self = .version
        default:
            throw MenuItemsError.invalidArguments
        }
    }

    private static func ignorePatterns(_ arguments: [String]) throws -> [String] {
        guard arguments.count.isMultiple(of: 2) else { throw MenuItemsError.invalidArguments }
        return try stride(from: 0, to: arguments.count, by: 2).map { index in
            guard arguments[index] == "--ignore" else { throw MenuItemsError.invalidArguments }
            return arguments[index + 1]
        }
    }
}
