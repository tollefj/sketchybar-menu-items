import MenuItems
import Testing

struct MenuExtraTests {
    let systemItem = MenuExtra(
        id: "1:0", app: "Control Center", bundleId: "com.apple.controlcenter",
        identifier: "com.apple.menuextra.clock", title: "Clock", x: 0
    )
    let thirdPartyItem = MenuExtra(
        id: "2:0", app: "Amphetamine", bundleId: "com.if.Amphetamine",
        identifier: nil, title: "Amphetamine", x: 0
    )

    @Test func matchesIdentifierGlob() {
        #expect(systemItem.matches("com.apple.menuextra.*"))
    }

    @Test func matchesBundleIdExactly() {
        #expect(thirdPartyItem.matches("com.if.Amphetamine"))
    }

    @Test func matchesCaseInsensitively() {
        #expect(systemItem.matches("CONTROL CENTER"))
        #expect(thirdPartyItem.matches("amphetamine"))
    }

    @Test func doesNotMatchPartialWithoutGlob() {
        #expect(!systemItem.matches("clo"))
        #expect(systemItem.matches("clo*"))
    }

    @Test func doesNotMatchUnrelated() {
        #expect(!thirdPartyItem.matches("com.apple.*"))
    }
}
