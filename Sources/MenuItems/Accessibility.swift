import ApplicationServices

public enum Accessibility {
    public static func isTrusted(prompt: Bool) -> Bool {
        let key = "AXTrustedCheckOptionPrompt"
        return AXIsProcessTrustedWithOptions([key: prompt] as CFDictionary)
    }

    static func attribute<T>(_ element: AXUIElement, _ name: String) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
        return value as? T
    }

    static func string(_ element: AXUIElement, _ name: String) -> String? {
        guard let value: String = attribute(element, name), !value.isEmpty else { return nil }
        return value
    }

    static func position(_ element: AXUIElement) -> CGPoint? {
        guard let value: AXValue = attribute(element, kAXPositionAttribute) else { return nil }
        var point = CGPoint.zero
        return AXValueGetValue(value, .cgPoint, &point) ? point : nil
    }

    static func size(_ element: AXUIElement) -> CGSize? {
        guard let value: AXValue = attribute(element, kAXSizeAttribute) else { return nil }
        var size = CGSize.zero
        return AXValueGetValue(value, .cgSize, &size) ? size : nil
    }
}
