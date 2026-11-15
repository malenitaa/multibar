# Multibar

**Organize your macOS menu bar by context, not by clutter.**

Multibar lets you create your own groups in the menu bar. Each group is an icon you choose (a
symbol or an emoji) that opens a list of whatever belongs to that context: apps, files,
folders, a VM, a shortcut, a website and, later on, the real menu bar icons of other apps.

```
 ┌───────────── menu bar ─────────────┐
 │   …   💼 Work    ✅ Tasks    🔋  📶  │
 └────────┬──────────┬────────────────┘
          │          └─ Claude · Maccy · Reminders
          └─ Teams · Passwords · Windows VM
```

> **Status: early development.** The repository currently holds the specification, the
> architecture and a pending test per acceptance criterion. Nothing is usable yet. Follow the
> [roadmap](HANDOFF.md#roadmap) or pick an [issue](https://github.com/malenitaa/multibar/issues).

## Why another menu bar app
Tools like Bartender and Ice organize the menu bar by *visibility*: shown, hidden, always
hidden. Multibar organizes it by *context*:

- **Groups by category.** "Work", "Tasks", "Personal": each one its own icon, with its own
  contents.
- **Icons and launchers together.** A group can hold things to open (apps, files, URLs) next
  to, in v2, the live menu bar icons of other apps.
- **Safe by design.** No network, no telemetry, no reading of your data, and the fewest
  permissions that make each feature work. See [Privacy and security](#privacy-and-security).

## Planned features
**v1 — launcher groups** (no special permissions)
- Create groups with a name and an SF Symbol or emoji as icon.
- Drag apps, files and folders onto a group's icon to add them.
- Pick installed apps from a list with checkboxes.
- Add URLs, including custom schemes such as `utm://` (VMs) and `shortcuts://` (Shortcuts).
- Reorder and remove; everything is remembered across restarts.
- Optional launch at login.

**v2 — organizer** (under investigation, see
[#8](https://github.com/malenitaa/multibar/issues/8))
- Hide other apps' menu bar icons and show them inside a group.

The full behaviour, with acceptance criteria, is in [SPEC.md](SPEC.md).

## Privacy and security
- Multibar **never connects to the internet** and collects nothing. The lint step fails if
  the code references networking APIs.
- It **does not read your data**: not your windows, documents or clipboard. It only knows
  what you put in a group.
- v1 needs **no system permissions**. Any permission v2 requires will be documented and
  justified in [SECURITY.md](SECURITY.md) before it ships, and the launcher will keep working
  without it.
- Your configuration is a plain JSON file at
  `~/Library/Application Support/Multibar/config.json`.
- The code is open so you can check all of the above yourself.

## Requirements
- macOS 15 or later.
- To build: Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  (`brew install xcodegen`).

## Build and run
```bash
xcodegen generate
open Multibar.xcodeproj
```
The `.xcodeproj` is not in the repository: it is generated from `project.yml`. To sign, pick
your team in Xcode (Signing & Capabilities) or pass `DEVELOPMENT_TEAM=<id>` to `xcodebuild`.

## Tests and lint
```bash
swift test --package-path Core
./scripts/lint.sh          # --fix to format in place
```

## Contributing
Issues and pull requests are welcome: bugs, ideas and new features. Start with
[CONTRIBUTING.md](CONTRIBUTING.md). To report a vulnerability, see [SECURITY.md](SECURITY.md).

## License
[Apache-2.0](LICENSE): you can use, modify and redistribute it, commercially too, as long as
you state which files you changed.
