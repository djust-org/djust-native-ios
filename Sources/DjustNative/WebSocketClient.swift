// WebSocketClient.swift
//
// LVN-III PR-2: WebSocket transport for djust LiveView. Wraps
// `URLSessionWebSocketTask` so the receive loop produces decoded
// `PatchFrame` values via msgpack.
//
// The msgpack decoder is itself a stub in this PR — the full integration
// (likely via swift-msgpack or Apple's Codable + manual layer) lands in
// PR-3 alongside the patch applicator. Transport-level reconnect /
// sticky-LiveView restore semantics (per djust ADRs 011/014/018) land
// in a later PR.

import Foundation

/// Errors the WS client can surface.
public enum DjustWSError: Error {
    case invalidURL
    case decoderUnimplemented(String)
    case disconnected
}

/// Transport for djust LiveView WebSocket frames.
///
/// Eventually:
/// ```swift
/// let client = WebSocketClient(url: liveViewURL, platform: .swiftui)
/// try await client.connect()
/// for try await frame in client.frames() {
///     // apply patches
/// }
/// ```
public final class WebSocketClient {
    public enum Platform: String {
        case swiftui
        case compose // for parity / cross-test purposes
    }

    public let url: URL
    public let platform: Platform

    private var task: URLSessionWebSocketTask?
    private let session: URLSession

    public init(url: URL, platform: Platform = .swiftui, session: URLSession = .shared) {
        self.url = url
        self.platform = platform
        self.session = session
    }

    /// Build the connection URL by appending `?platform=swiftui`.
    /// Matches the server-side parsing in
    /// `python/djust/websocket.py` (LVN-I PR-3).
    public var connectionURL: URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "platform", value: platform.rawValue))
        components.queryItems = items
        return components.url ?? url
    }

    /// Open the WebSocket connection.
    public func connect() {
        let task = session.webSocketTask(with: connectionURL)
        task.resume()
        self.task = task
    }

    /// Async sequence of decoded frames. Stub: actual msgpack decoding
    /// lands in LVN-III PR-3.
    public func frames() -> AsyncThrowingStream<PatchFrame, Error> {
        AsyncThrowingStream { continuation in
            // PR-3 implements:
            //   1. receive loop on self.task
            //   2. msgpack decode into PatchFrame
            //   3. version ordering check
            //   4. continuation.yield(frame) / continuation.finish(throwing:)
            continuation.finish(throwing: DjustWSError.decoderUnimplemented(
                "msgpack decoder ships in djust-native-ios PR-3 (djust#1579)"
            ))
        }
    }

    /// Send an event payload back to the server. Matches the browser's
    /// WS event encoding so the same `@event_handler` Python decorators
    /// fire across all three clients.
    public func sendEvent(name: String, params: [String: String]) async throws {
        // PR-5: msgpack-encode the event payload + send via self.task.
        throw DjustWSError.decoderUnimplemented(
            "event sender ships in djust-native-ios PR-5 (djust#1579)"
        )
    }

    /// Close the connection.
    public func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }
}
