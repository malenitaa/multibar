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
| What the UI shows and the actions it can ask for | `App/UI/AppModel.swift` |
| Other apps' menu bar icons (the only code that uses Accessibility) | `App/Adapters/AccessibilityMenuBarIcons.swift` |
| The marker that hides icons | `App/UI/MenuBar/HidingMarker.swift` |
| Menu bar icons and group strips | `App/UI/MenuBar/` |
| Settings window | `App/UI/Settings/` |
| Xcode project | generated from `project.yml` with `xcodegen generate` |
| App icon | drawn by `scripts/make-icon.swift`, which writes every size into `App/Assets.xcassets/AppIcon.appiconset` |

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

## Configuration file
`~/Library/Application Support/Usherette/config.json`, written by `JSONConfigStore`
(pretty-printed, keys sorted, saved atomically):

```json
{
  "groups" : [
    {
      "icon" : { "kind" : "symbol", "value" : "briefcase" },
      "id" : "ECFB19B7-A4DB-4A3C-BA78-8BCAFD201FE0",
      "items" : [
        {
          "bundleID" : "com.microsoft.teams2",
          "id" : "A2D3EEAC-5699-4268-9595-D1B9786C8CFC",
          "kind" : "app",
          "name" : "Microsoft Teams",
          "target" : "/Applications/Microsoft Teams.app"
        }
      ],
      "name" : "Work"
    }
  ],
  "version" : 1
}
```

- `icon.kind` is `symbol` or `emoji`; an item's `kind` is `app`, `file`, `folder` or `url`.
- Fields this build does not know are ignored. A file that is not valid, or whose `version`
  is not the current one, is renamed to `config.json.bak-<UTC date>` and the app starts
  empty; `load()` reports it in `ConfigLoadResult.recovery`.
- Changing the format means raising `Configuration.currentVersion` and adding a migration in
  `JSONConfigStore`; never reinterpret an old file silently.

## Planned technical pieces
- **One `NSStatusItem` per group** (`MenuBarController`), all rebuilt when the groups change.
  macOS puts each new item to the left of the previous ones, so they are created last group
  first for the bar to read in configuration order. The icon is an
  `NSImage(systemSymbolName:)`, a plain circle if that symbol does not exist, or the emoji as
  the button title. For now each icon opens a plain menu; the strip comes with the items.
- **Finding a way in:** the app has no Dock icon, so with no groups, or with something to
  report, the settings window opens at launch. Opening the app again also shows it.
- **Hiding icons:** `HidingMarker` is a status item that, widened past the notch, pushes
  everything on its left out of the bar (`HidingGeometry` has the rule). Group icons get a
  seeded position at the right end the first time they are created, so they are never on the
  hidden side.
- **Placing icons:** `ArrangeMenuBarIcons` moves the icons of grouped apps behind the marker
  and the others back, with a ⌘-drag posted by `AccessibilityMenuBarIcons`. It runs when an app
  is added to or removed from a group, when hiding is turned on, and at launch for icons found
  in view. Each drag blocks the main thread for under a second.
- **Opening a hidden icon:** `OpenMenuBarIcon` reveals, waits for the icon, presses it through
  `AccessibilityMenuBarIcons`, waits for that app's new window to go away, and hides again.
- **Trying it without touching the real configuration:** run the binary with
  `USHERETTE_CONFIG_DIR=/some/folder`.
- **The group's strip:** a borderless, non-activating `NSPanel` anchored under the group's
  status item, with one button per item; it closes when focus moves elsewhere.
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
1. Create two groups in the settings window: two icons appear in the menu bar, in order.
   An unknown symbol name shows a circle; an empty name is refused with a message.
2. Drop an app from Finder on an icon: it appears in the menu with its icon.
3. Click the item: the app opens.
4. Quit and reopen Usherette: everything is the same.
5. With Accessibility allowed and hiding on, add two menu bar apps to groups: each icon is
   moved behind the marker by itself and leaves the bar; no other icon changes place, and the
   group icons stay. Remove one from its group: its icon comes back.
6. With Accessibility allowed, add one of those apps to a group and pick it from the group's
   menu: its icon comes back, its menu opens, and the icon leaves again when the menu closes.
7. Quit Usherette: every icon is back where it was.
