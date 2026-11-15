# Multibar — internal design

**Last updated:** 2026-11-15

## Where everything is
| What | Where |
|---|---|
| Domain (groups, items, use cases) and ports | `Core/Sources/MultibarCore/` |
| JSON configuration adapter | `Core/Sources/MultibarPersistence/` |
| Tests, one file per acceptance criterion | `Core/Tests/` |
| Composition (wires the graph) | `App/MultibarApp.swift` |
| System adapters (`NSWorkspace`, `SMAppService`, icons) | `App/Adapters/` (created in stage 2) |
| Menu bar, menu and settings window | `App/UI/` (created in stage 2) |
| Xcode project | generated from `project.yml` with `xcodegen generate` |

Dependency rule (ADR 0002): `App` → `MultibarPersistence` → `MultibarCore`. `Core/Sources`
does not import AppKit, SwiftUI or ServiceManagement, and no source file references networking
APIs; `./scripts/lint.sh` checks both.

## Planned technical pieces
- **One `NSStatusItem` per group**, created and destroyed when the configuration changes. The
  icon is an `NSImage(systemSymbolName:)` or the emoji as the button title.
- **Dropping on the icon:** `NSStatusBarButton` is not meant to be subclassed; a transparent
  subview that implements `NSDraggingDestination` and accepts `.fileURL` is added to it. If
  that does not work well, plan B is dropping on the settings window (see the AC-2 issue).
- **Opening:** apps with `NSWorkspace.openApplication(at:configuration:)`, resolved by bundle
  id; files, folders and URLs with `NSWorkspace.open(_:)`.
- **Installed apps list:** `/Applications`, `/System/Applications` and `~/Applications`.
- **Login item:** `SMAppService.mainApp`.

## Tests
| Level | Present? | Detail |
|---|---|---|
| Unit | Yes | Domain with fakes for the ports, Swift Testing |
| Integration | Yes | `MultibarPersistence` against a temporary directory (AC-7, AC-8) |
| End-to-end | **No (debt)** | No UI tests for the menu bar in v1: XCUITest handles `NSStatusItem` poorly. Checked by hand with the list below |
| Evals | Not applicable | No LLM |
| Performance | Not applicable | The spec has no numbers |
| Dependency vulnerabilities | Not applicable yet | `Core` has no dependencies; Dependabot watches in case they appear |

### Manual check before each release
1. Create two groups: two icons appear in the menu bar, in order.
2. Drop an app from Finder on an icon: it appears in the menu with its icon.
3. Click the item: the app opens.
4. Quit and reopen Multibar: everything is the same.
