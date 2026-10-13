// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "sketchybar-menu-items",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "menu-items", targets: ["menu-items"])
    ],
    targets: [
        .target(name: "MenuItems"),
        .executableTarget(name: "menu-items", dependencies: ["MenuItems"]),
        .testTarget(name: "MenuItemsTests", dependencies: ["MenuItems"])
    ]
)
