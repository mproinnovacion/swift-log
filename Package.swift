// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Log",
    products: [
        .library(
            name: "Log",
            targets: ["Log"]
		  )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Log",
            dependencies: []
		  ),
        .testTarget(
            name: "LogTests",
            dependencies: ["Log"]
		  )
    ]
)
