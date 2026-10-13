import Darwin

public struct MenuExtra: Encodable, Equatable, Sendable {
    public let id: String
    public let app: String
    public let bundleId: String
    public let identifier: String?
    public let title: String
    public let x: Double

    public init(id: String, app: String, bundleId: String, identifier: String?, title: String, x: Double) {
        self.id = id
        self.app = app
        self.bundleId = bundleId
        self.identifier = identifier
        self.title = title
        self.x = x
    }

    public func matches(_ pattern: String) -> Bool {
        [identifier, bundleId, title, app].compactMap { $0 }.contains { field in
            fnmatch(pattern.lowercased(), field.lowercased(), 0) == 0
        }
    }
}
