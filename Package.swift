// swift-tools-version: 5.9
//
// djust-native-ios — Native iOS (SwiftUI) client for djust LiveView.
//
// LVN-III PR-1 (djust-org/djust#1579): SwiftPM scaffold. The actual
// transport / msgpack decoder / patch applicator / widget renderers
// land in subsequent PRs against this repo. See README for the full
// PR sequence and ADR-019 in djust-org/djust for architectural context.

import PackageDescription

let package = Package(
    name: "DjustNative",
    platforms: [
        .iOS(.v16),  // matches max-companion's deployment target
    ],
    products: [
        .library(
            name: "DjustNative",
            targets: ["DjustNative"]
        ),
    ],
    dependencies: [
        // msgpack decoder + WebSocket transport land in LVN-III PR-2.
        // Likely candidates:
        //   - swift-msgpack (or Apple's Codable + custom layer)
        //   - URLSessionWebSocketTask (no external dep needed)
    ],
    targets: [
        .target(
            name: "DjustNative",
            dependencies: [],
            path: "Sources/DjustNative"
        ),
        .testTarget(
            name: "DjustNativeTests",
            dependencies: ["DjustNative"],
            path: "Tests/DjustNativeTests"
        ),
    ]
)
