// DjustLiveView.swift
//
// Public SwiftUI entry point. LVN-III PR-1: stub declaration so
// downstream consumers can `import DjustNative` and reference
// `DjustLiveView` immediately. The actual WebSocket transport, msgpack
// decoding, and patch applicator land in LVN-III PRs 2-6 per
// djust-org/djust#1579.
//
// Today: displays a placeholder explaining the implementation status
// and pointing at the tracking issue.

import SwiftUI

/// Native SwiftUI client for djust LiveView.
///
/// Eventually:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         DjustLiveView(url: URL(string: "ws://127.0.0.1:8111/ws/live/")!)
///     }
/// }
/// ```
///
/// Connects to the LiveView WebSocket with `?platform=swiftui`,
/// consumes the existing Patch opcode stream, and renders true
/// SwiftUI widgets per the v1 vocabulary (see `widgetTags`).
public struct DjustLiveView: View {
    /// The djust LiveView WebSocket URL.
    /// `?platform=swiftui` is appended automatically.
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text("djust-native-ios")
                .font(.headline)
            Text("Implementation in progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("djust-org/djust#1579")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
