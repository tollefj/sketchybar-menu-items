public enum MenuItemsError: Error, Equatable, CustomStringConvertible {
    case notFound(String)
    case pressFailed(String, Int32)
    case untrusted
    case invalidArguments

    public var description: String {
        switch self {
        case .notFound(let target): "no menu item matches '\(target)'"
        case .pressFailed(let target, let code): "pressing '\(target)' failed with AXError \(code)"
        case .untrusted: "Accessibility permission missing for the calling process, run 'menu-items trust'"
        case .invalidArguments: "invalid arguments"
        }
    }
}
