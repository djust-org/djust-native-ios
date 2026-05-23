# MAX Companion pilot integration (LVN-III PR-7)

Pilot screen for `djust-native-ios` v0.1: re-implement MAX Companion's
`HomeView` (`djust-mobile-poc/medicare/views.py`) as a native variant.

## Server-side setup

Add a `home.swiftui.html` variant alongside the existing `home.html`
in `djust-mobile-poc/medicare/templates/medicare/`:

```html
{# medicare/home.swiftui.html #}
<Stack spacing="12" padding="16">
    <Text font="title">Hello, {{ first_name }}</Text>

    {% if show_alert %}
    <Stack padding="12" foregroundColor="#14457E">
        <Text font="headline">Your screening is due</Text>
        <Text>{{ screening }}</Text>
        <Button dj-tap="dismiss_alert">Dismiss</Button>
    </Stack>
    {% endif %}

    <List>
        {% for tile in tiles %}
        <Stack>
            <Text font="headline">{{ tile.label }}</Text>
            <Text>{{ tile.stat }}</Text>
        </Stack>
        {% endfor %}
    </List>
</Stack>
```

No Python view changes needed — the same `HomeView`, `mount`,
`dismiss_alert` handler, BeneficiaryPreferences write-back all work
unchanged. The renderer abstraction picks the variant when the WS
handshake arrives with `?platform=swiftui`.

## Client-side wiring

Replace the existing `WKWebView` in the iOS app with `DjustLiveView`:

```swift
import SwiftUI
import DjustNative

@main
struct MaxCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            DjustLiveView(
                url: URL(string: "ws://127.0.0.1:8111/ws/live/")!
            )
        }
    }
}
```

## Acceptance criteria

Pinned by the LVN-III tracking issue (djust#1579):

- [ ] MAX home screen renders visually equivalent on iOS sim vs WebView
- [ ] `dismiss_alert` event round-trips through the unchanged Python
      `HomeView.dismiss_alert` handler
- [ ] `BeneficiaryPreferences` write-back from max-companion PR #7
      survives a relaunch (proves the native client respects the ORM's
      persistence)
- [ ] Bundle-size delta documented (`MAX Companion.app` native-only
      vs WebView+Toga)

## Known gaps blocking full end-to-end

This PR ships the pilot recipe and the integration shape. The
end-to-end pilot requires:

1. **msgpack decoder** (PR-2's `WebSocketClient.frames()` currently
   throws `decoderUnimplemented`). Either swift-msgpack or a manual
   Codable bridge.
2. **PatchApplicator per-op mutations** (PR-3 ships the dispatch shape;
   the per-op tree mutations need the SwiftUI binding layer).
3. **Native template variants** in max-companion (the `home.swiftui.html`
   above is the recipe — a future PR against djust-mobile-poc adds it).
4. **Bundle-size measurement** — both builds run on the same iOS sim
   with identical content. Documented in the LVN-III tracking issue
   when measured.

These are the remaining engineering pieces — the structural seams,
type contracts, and integration shape are all in place. Each gap is
its own focused follow-up PR.
