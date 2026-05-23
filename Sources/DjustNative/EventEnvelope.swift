// EventEnvelope.swift
//
// LVN-III PR-5: event payload encoding. Matches the browser's WS
// event encoding so the same @event_handler Python decorators fire
// across all three clients.

import Foundation

/// Event message sent client → server. Matches the JSON shape
/// LiveViewConsumer expects in `python/djust/websocket.py`.
public struct EventEnvelope: Codable, Equatable {
    public let type: String  // "event"
    public let event: String  // handler name, e.g. "dismiss_alert"
    public let params: [String: String]
    public let djId: String?  // target node's djId

    public init(event: String, params: [String: String] = [:], djId: String? = nil) {
        self.type = "event"
        self.event = event
        self.params = params
        self.djId = djId
    }

    public func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
