# Multibar

**Organize your macOS menu bar by context, not by clutter.**

Multibar lets you create your own groups in the menu bar. Each group is an icon you choose (a
symbol or an emoji) that opens a list of whatever belongs to that context: apps, files,
folders, a VM, a shortcut, a website. Hide the individual icons with macOS's own setting and
keep one icon per context.

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
- **Anything you open goes in a group.** Apps, files, folders, URLs, VMs, Shortcuts.
- **Safe by design.** No network, no telemetry, no reading of your data, and none of the
  Accessibility or Screen Recording permissions other menu bar managers ask for. See
  [Privacy and security](#privacy-and-security).

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
- Hide other apps' icons with macOS's own menu bar setting and reach those apps from a group,
  without Multibar ever touching them.

The full behaviour, with acceptance criteria, is in [SPEC.md](SPEC.md).

## Privacy and security
- Multibar **never connects to the internet** and collects nothing. The lint step fails if
  the code references networking APIs.
- It **does not read your data**: not your windows, documents or clipboard. It only knows
  what you put in a group.
- It **never asks for Accessibility or Screen Recording**, the permissions that would let an
  app see your screen or control other apps. v1 needs no permissions at all.
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
