// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimpleWhoisGeo",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "SimpleWhoisGeo",
            path: "Sources/SimpleWhoisGeo"
        )
    ]
)
