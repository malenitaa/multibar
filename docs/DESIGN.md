# Usherette — internal design

**Last updated:** 2026-11-15

## Where everything is
| What | Where |
|---|---|
| Domain types and rules | `Core/Sources/UsheretteCore/Domain/` |
| Use cases, one per file | `Core/Sources/UsheretteCore/UseCases/` |
| Ports (protocols the domain needs) | `Core/Sources/UsheretteCore/Ports/` |
| JSON configuration adapter | `Core/Sources/UsherettePersistence/` |
| Tests, one file per acceptance criterion | `Core/Tests/` |
| Composition (wires the graph) | `App/UsheretteApp.swift` |
| System adapters (`NSWorkspace`, `SMAppService`, icons) | `App/Adapters/` (created in stage 2) |
| Menu bar icons and menus | `App/UI/MenuBar/` (created in stage 2) |
| Settings window | `App/UI/Settings/` (created in stage 2) |
| Xcode project | generated from `project.yml` with `xcodegen generate` |

Dependency rule (ADR 0002): `App` → `UsherettePersistence` → `UsheretteCore`. `Core/Sources`
does not import AppKit, SwiftUI or ServiceManagement, and no source file references networking
APIs; `./scripts/lint.sh` checks both.

## Design rules
The layout exists so that a change touches one place. The rules are SOLID applied to this
codebase:

| Principle | What it means here |
|---|---|
| **Single responsibility** | One type per file, one use case per file. A view draws, a use case decides, an adapter talks to the system. If a file needs "and" to be described, it is two files |
| **Open/closed** | New behaviour arrives as a new file, not as edits spread over old ones: a new item kind is a new case plus its tests; a new system integration is a new adapter behind an existing or new port |
| **Liskov substitution** | Anything that implements a port can replace any other implementation. The tests prove it: every use case runs against fakes, the app runs the same use cases against the real adapters |
| **Interface segregation** | Ports are small and named after what the domain needs (`Launcher`, `ConfigStore`), never after the system behind them. No use case receives a port with methods it does not call |
| **Dependency inversion** | `UsheretteCore` defines the ports and depends on nothing. Adapters depend on the core. Only `App/UsheretteApp.swift` knows the concrete types |

### Where does a change go?
| I want to… | Touch |
|---|---|
| Add something a person can do | a new file in `UseCases/`, its test in `Core/Tests/`, and the UI that calls it |
| Add a kind of item | `Domain/`, plus the adapter that opens it if the existing one cannot |
| Talk to a new part of macOS | a new port in `Ports/` and a new adapter in `App/Adapters/`, wired in `App/UsheretteApp.swift` |
| Change how the configuration is stored | only `UsherettePersistence` |
| Change how a menu or the settings look | only `App/UI/` |

Folders that never exist: `Utils/`, `Helpers/`, `Common/`, `Misc/`. If it is unclear where
something goes, it is not yet clear what it is.

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
| Integration | Yes | `UsherettePersistence` against a temporary directory (AC-7, AC-8) |
| End-to-end | **No (debt)** | No UI tests for the menu bar in v1: XCUITest handles `NSStatusItem` poorly. Checked by hand with the list below |
| Evals | Not applicable | No LLM |
| Performance | Not applicable | The spec has no numbers |
| Dependency vulnerabilities | Not applicable yet | `Core` has no dependencies; Dependabot watches in case they appear |

### Manual check before each release
1. Create two groups: two icons appear in the menu bar, in order.
2. Drop an app from Finder on an icon: it appears in the menu with its icon.
3. Click the item: the app opens.
4. Quit and reopen Usherette: everything is the same.
