import AppKit
import ApplicationServices

public enum MenuExtras {
    private static let timeout: Float = 0.25

    public static func list() -> [MenuExtra] {
        let apps = NSWorkspace.shared.runningApplications.filter(canOwnMenuExtras)
        let results = Results(count: apps.count)
        DispatchQueue.concurrentPerform(iterations: apps.count) { index in
            results.set(index, extras(of: apps[index]))
        }
        return results.all.flatMap { $0 }.sorted { $0.x > $1.x }
    }

    public static func list(ignoring patterns: [String]) -> [MenuExtra] {
        list().filter { extra in !patterns.contains(where: extra.matches) }
    }

    public static func press(_ target: String) throws {
        let item = try element(for: target)
        let result = AXUIElementPerformAction(item, kAXPressAction as CFString)
        guard result == .success || result == .cannotComplete else {
            throw MenuItemsError.pressFailed(target, result.rawValue)
        }
    }

    private static func element(for target: String) throws -> AXUIElement {
        if let (pid, index) = parse(target, separator: ":", Int.init) {
            let items = children(of: application(pid))
            guard items.indices.contains(index) else { throw MenuItemsError.notFound(target) }
            return items[index]
        }
        if let (pid, identifier) = parse(target, separator: "/", { $0 }) {
            let item = children(of: application(pid)).first {
                Accessibility.string($0, kAXIdentifierAttribute) == identifier
            }
            guard let item else { throw MenuItemsError.notFound(target) }
            return item
        }
        guard let extra = list().first(where: { $0.matches(target) }) else {
            throw MenuItemsError.notFound(target)
        }
        return try element(for: extra.id)
    }

    private static func parse<T>(_ target: String, separator: Character, _ transform: (String) -> T?) -> (pid_t, T)? {
        let parts = target.split(separator: separator, maxSplits: 1).map(String.init)
        guard parts.count == 2, let pid = pid_t(parts[0]), let value = transform(parts[1]) else { return nil }
        return (pid, value)
    }

    private static func canOwnMenuExtras(_ app: NSRunningApplication) -> Bool {
        guard let url = app.bundleURL, url.pathExtension == "app" else { return false }
        return !url.deletingLastPathComponent().path.contains(".app/Contents/Frameworks")
            && !url.path.contains("/WebKit.framework/")
    }

    private static func extras(of app: NSRunningApplication) -> [MenuExtra] {
        let pid = app.processIdentifier
        let name = app.localizedName ?? "Unknown"
        return children(of: application(pid)).enumerated().compactMap { index, item in
            guard let position = Accessibility.position(item),
                  let size = Accessibility.size(item), size.width > 0 else { return nil }
            let title = Accessibility.string(item, kAXTitleAttribute)
                ?? Accessibility.string(item, kAXDescriptionAttribute)
                ?? Accessibility.string(item, kAXHelpAttribute)
                ?? name
            return MenuExtra(
                id: "\(pid):\(index)",
                app: name,
                bundleId: app.bundleIdentifier ?? "",
                identifier: Accessibility.string(item, kAXIdentifierAttribute),
                title: title,
                x: position.x
            )
        }
    }

    private static func application(_ pid: pid_t) -> AXUIElement {
        let element = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(element, timeout)
        return element
    }

    private static func children(of app: AXUIElement) -> [AXUIElement] {
        guard let bar: AXUIElement = Accessibility.attribute(app, "AXExtrasMenuBar") else { return [] }
        return Accessibility.attribute(bar, kAXChildrenAttribute) ?? []
    }
}

private final class Results: @unchecked Sendable {
    private var storage: [[MenuExtra]]
    private let lock = NSLock()

    init(count: Int) { storage = Array(repeating: [], count: count) }

    func set(_ index: Int, _ value: [MenuExtra]) { lock.withLock { storage[index] = value } }

    var all: [[MenuExtra]] { lock.withLock { storage } }
}
