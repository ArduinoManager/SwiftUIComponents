// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIComponents",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftUIComponents",
            targets: ["SwiftUIComponents"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.4"),
        //.package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", .upToNextMinor(from: "0.1.2")), // <-
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftUIComponents",
            dependencies: [
                .product(name: "Introspect", package: "Introspect"),
            ]
            //, resources: [.process("Media.xcassets")] // If I need to export any Asset
        )
    ]
)
