# ADR 0001 · Language: Swift

**Date:** 2026-11-13 · **Status:** accepted

## Context
Multibar lives in the macOS menu bar: it creates dynamic `NSStatusItem`s (one per group),
receives files dropped on them, opens apps with `NSWorkspace`, registers as a login item with
`SMAppService`. It only runs on macOS.

## Decision
**Swift 6**, AppKit for the menu bar (`NSStatusItem`s created and destroyed as the
configuration changes) and SwiftUI for the settings window. The project is generated with
XcodeGen (`project.yml`). The domain lives in a Swift package (`Core/`) that is tested with
`swift test` without opening Xcode.

## Alternatives considered
- **Tauri (Rust + web):** worth it for a cross-platform app. This one is not, and dynamic menu
  bar icons and dropping on the icon end up in native code anyway, with a bridge in between.
- **SwiftUI `MenuBarExtra` only:** convenient for one fixed icon, but the number of groups is
  decided by the user at runtime and it cannot register the icon as a drag destination. AppKit
  is used for the bar.
- **Electron / TypeScript:** a heavy runtime for an app that should use almost nothing.
- **Python (rumps/PyObjC):** fragile packaging and no clear path to v2.

## Consequences
- `xcodebuild` and `swift test` must be green on every iteration (Swift is more error-prone
  with APIs that change between macOS versions and with `@MainActor`).
- Minimum target `[assumed]` macOS 15.
- No sandbox (`[assumed]`): opening arbitrary files from a sandbox requires a bookmark per
  item. Not on the Mac App Store. (The original second reason, Accessibility in v2, no longer
  applies: see ADR 0003.)
