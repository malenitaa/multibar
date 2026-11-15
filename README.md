# Usherette

**Organize your macOS menu bar by context, not by clutter.**

Usherette lets you create your own groups in the menu bar. Each group is an icon you choose (a
symbol or an emoji) that opens a strip with whatever belongs to that context: apps, files,
folders, a VM, a shortcut, a website. Hide the individual icons and keep one icon per
context.

```
 ┌───────────── menu bar ─────────────┐
 │   …   💼 Work    ✅ Tasks    🔋  📶  │
 └────────┬──────────┬────────────────┘
          │          └─ Claude · Maccy · Reminders
          └─ Teams · Passwords · Windows VM
```

> **Status: early development.** You can create groups, hide other apps' icons behind a
> marker, put a menu bar app in a group and open its menu from there (on a display with a
> notch). Groups cannot hold apps, files or URLs to launch yet. Follow the
> [roadmap](HANDOFF.md#roadmap) or pick an [issue](https://github.com/malenitaa/usherette/issues).

## Why another menu bar app
Tools like Bartender and Ice organize the menu bar by *visibility*: shown, hidden, always
hidden. Usherette organizes it by *context*:

- **Groups by category.** "Work", "Tasks", "Personal": each one its own icon, with its own
  contents.
- **Anything you open goes in a group.** Apps, files, folders, URLs, VMs, Shortcuts.
- **Safe by design.** No network, no telemetry, no reading of your data, and no system
  permissions unless you turn on a feature that needs one. Never Screen Recording. See
  [Privacy and security](#privacy-and-security).

## Planned features
**v1 — launcher groups** (no special permissions)
- Create groups with a name and an SF Symbol or emoji as icon.
- Drag apps, files and folders onto a group's icon to add them.
- Pick installed apps from a list with checkboxes.
- Add URLs, including custom schemes such as `utm://` (VMs) and `shortcuts://` (Shortcuts).
- Reorder and remove; everything is remembered across restarts.
- Optional launch at login.

**v2 — organizer** (first slice working, see
[#14](https://github.com/malenitaa/usherette/issues/14))
- Hide other apps' icons and reach those apps from a group, with no permissions.
- Optional: open other apps' real menu bar menus from a group. This one module asks for
  Accessibility and is off unless you turn it on.

**Later**
- A hotkey per group and search across your groups.
- Profiles ("Work", "Focus") and triggers that switch them.
- Shortcuts and AppleScript support.
- Custom items: system readings, labels, spacers.

The full behaviour, with acceptance criteria, is in [SPEC.md](SPEC.md).

## Privacy and security
- Usherette **never connects to the internet** and collects nothing. The lint step fails if
  the code references networking APIs.
- It **does not read your data**: not your windows, documents or clipboard. It only knows
  what you put in a group.
- It holds **no system permissions by default**. A feature that needs one is off until you
  turn it on, and the rest keeps working without it. The only feature that will ask for
  Accessibility is the optional module that shows other apps' icons inside a group.
- It **never asks for Screen Recording**.
- Your configuration is a plain JSON file at
  `~/Library/Application Support/Usherette/config.json`.
- The code is open so you can check all of the above yourself.

## Requirements
- macOS 15 or later.
- To build: Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  (`brew install xcodegen`).

## Build and run
```bash
xcodegen generate
open Usherette.xcodeproj
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
