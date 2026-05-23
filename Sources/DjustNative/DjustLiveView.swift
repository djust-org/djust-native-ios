// DjustLiveView.swift — wired (LVN-III PR-6, djust#1579)
//
// Composes WebSocketClient + PatchApplicator + WidgetRenderer +
// EventEnvelope into the public SwiftUI entry point.

import SwiftUI

public struct DjustLiveView: View {
    public let url: URL

    @StateObject private var model: LiveViewModel

    public init(url: URL) {
        self.url = url
        _model = StateObject(wrappedValue: LiveViewModel(url: url))
    }

    public var body: some View {
        Group {
            if let root = model.root {
                WidgetRenderer(node: root, onEvent: model.send)
            } else {
                ProgressView("Connecting to \(url.absoluteString)…")
            }
        }
        .task { await model.start() }
    }
}

@MainActor
final class LiveViewModel: ObservableObject {
    @Published var root: VNode?

    private let client: WebSocketClient
    private let applicator = PatchApplicator()

    init(url: URL) {
        self.client = WebSocketClient(url: url, platform: .swiftui)
    }

    func start() async {
        client.connect()
        do {
            for try await frame in client.frames() {
                _ = try applicator.apply(frame: frame)
                root = applicator.root
            }
        } catch {
            // Stream throws decoderUnimplemented today (PR-3); per-op
            // SwiftUI binding ships in PR-7's MAX Companion pilot.
        }
    }

    func send(name: String, params: [String: String]) {
        Task {
            try? await client.sendEvent(name: name, params: params)
        }
    }
}
