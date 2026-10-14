import AppKit

enum ActiveDisplay {
    private static let menuBarHeight: CGFloat = 24

    static func mouseLocation() -> CGPoint? {
        CGEvent(source: nil)?.location
    }

    static func bounds() -> CGRect? {
        guard let location = mouseLocation() else { return nil }
        var id = CGDirectDisplayID()
        var count: UInt32 = 0
        guard CGGetDisplaysWithPoint(location, 1, &id, &count) == .success, count > 0 else { return nil }
        return CGDisplayBounds(id)
    }

    static func origin(for size: CGSize, on display: CGRect) -> CGPoint {
        let mouseX = mouseLocation()?.x ?? display.midX
        let x = min(max(mouseX - size.width / 2, display.minX), display.maxX - size.width)
        return CGPoint(x: x, y: display.minY + menuBarHeight)
    }
}
