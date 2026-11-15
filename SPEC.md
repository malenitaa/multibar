# Usherette — specification

**Status:** draft · **Last reviewed:** 2026-11-15 · Lines marked `[assumed]` were decided
without confirmation; change the line to veto them.

## 1. What it is and who it is for
Usherette is a macOS menu bar app that organizes the menu bar **by context**. You create
**groups**: each group is its own icon in the menu bar (a symbol or emoji you pick) and holds
whatever belongs to that context. A "Work" group with Teams, Passwords and a VM; a "Tasks"
group with your clipboard manager and your assistant. Clicking a group opens a **strip of
icons** right under the menu bar with what is in it.

The main idea has two halves: the strip holds the *real* menu bar icons of other apps, which
leave the main bar, and **profiles** swap what the whole bar shows ("Working", "Focus",
"Gaming"). Both depend on the opt-in organizer module (v2 below).

The goal is to bring together the best of the existing menu bar managers (a menu bar without
clutter) with something none of them do (grouping by category), while staying safe by design:
no network, no telemetry, and no system permission unless you turn on a feature that needs it.

It is built in two steps:
- **v1 — launcher groups.** Groups hold apps, files, folders and URLs to open. No special
  permissions.
- **v2 — organizer.** Other apps' icons are hidden from the main bar and reached from a
  group. Hiding them needs no permissions; an opt-in module opens their real menus from the
  group and asks for Accessibility. Spike #8 showed both work on macOS 27.2.

Section 7 lists what comes after.

## 2. What it does (v1: launcher groups)
1. Create, rename and delete groups; each group has a name and an icon (SF Symbol or emoji) and
   shows up as an independent icon in the menu bar.
2. Add things to a group by dragging them onto its icon: apps, files, folders.
3. Add installed apps from a list with checkboxes (checked = in the group, unchecked = out).
4. Add URLs, including custom schemes: a VM (`utm://start?name=…`), a shortcut
   (`shortcuts://run-shortcut?name=…`), a website.
5. Clicking an item in the strip opens it (app, file, folder or URL).
6. Reorder and remove items and groups.
7. Remember everything across restarts.
8. Optionally launch at login.

## 3. What it does not do (on purpose)
- **By default it does not read or control other apps' icons.** It can hide them, which needs
  no permission. Opening their menus from a group is an opt-in module (ADR 0003). It never
  captures the screen.
- **It does not run shell commands.** For "anything else" there are macOS Shortcuts
  (`shortcuts://`), which the user can see and control. Running commands from a config file
  opens a door that does not need to be open.
- It does not sync between Macs and it is not on the Mac App Store (the sandbox is
  a separate decision, see ADR 0003).
- No menu bar styling, clipboard history, calendar or weather (see the parity table in
  section 7 for why).

## 4. Non-negotiable principles
Changing any of these requires an ADR.
- **No network, no telemetry.** Usherette never connects to anything. `./scripts/lint.sh` fails
  if the code references networking APIs.
- **It does not read user data.** Usherette only knows what you put in a group. It never reads
  the content of windows, documents, the clipboard or other apps' menus.
- **No permissions by default; never Screen Recording.** Out of the box Usherette holds no
  system permission. A feature that needs one is off until you turn it on, one switch per
  feature, and everything else keeps working without it. Accessibility is only ever used by
  the opt-in organizer module (`docs/adr/0003-permissions.md`).
- **Your configuration is yours:** a readable JSON file at
  `~/Library/Application Support/Usherette/config.json`. A file that could not be read is never
  overwritten: a copy is kept first.
- **The domain does not import AppKit or SwiftUI** (see `docs/adr/0002-hexagonal-shape.md`).

## 5. Acceptance criteria
One per capability. Tests live in `Core/Tests/`; the ones not yet implemented are marked as
pending. Done so far: AC-1, AC-7, AC-8, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16.

| # | Given | When | Then | Test |
|---|---|---|---|---|
| AC-1 | there are no groups | I create "Work" with the `briefcase` icon and "Tasks" with ✅ | there are two groups with their name and icon, each with its own menu bar icon, in that order | `AC01CreateGroupTests` |
| AC-2 | the "Work" group | I drop `Microsoft Teams.app` on its icon | it becomes an item of kind app; dropping it again does not duplicate it | `AC02DropOnGroupTests` |
| AC-3 | the list of installed apps with checkboxes | I check Passwords and uncheck Teams | Passwords is in the group and Teams is out; nothing else changes | `AC03PickAppsWithCheckboxesTests` |
| AC-4 | the "Work" group | I add `utm://start?name=Windows`, a folder and a `.pdf` | they become a URL, a folder and a file, with a readable name | `AC04ItemKindsTests` |
| AC-5 | a group with an app, a file and a URL | I click each one | each opens with the method that matches its kind | `AC05OpenItemTests` |
| AC-6 | a group with three items, and two groups | I move the third item to the top, remove one and move a group | the new order is kept and what was removed does not come back | `AC06ReorderAndRemoveTests` |
| AC-7 | two groups with items | I quit and reopen Usherette | they are the same: groups, icons, items and order | `AC07PersistenceTests` |
| AC-8 | a broken `config.json`, or one from an unknown version | I open Usherette | it is not overwritten: it is kept as `config.json.bak-<date>`, the app starts empty and says so | `AC08BrokenConfigTests` |
| AC-9 | an item whose app or file no longer exists | I open the group | the item shows up disabled as "not found" and nothing crashes | `AC09MissingTargetTests` |
| AC-10 | the "Launch at login" option | I turn it on and off | Usherette is registered and unregistered as a login item | `AC10LaunchAtLoginTests` |
| AC-11 | icons placed on the left of Usherette's marker | I turn hiding on, and off again | they leave the menu bar and come back, with no permission asked; group icons are never hidden | `AC11HideIconsTests` |
| AC-12 | Accessibility allowed and the "Work" group | I add a menu bar app from the list, twice | it is in the group once, remembered by the app it belongs to; without the permission nothing is listed | `AC12AddMenuBarIconTests` |
| AC-13 | a hidden menu bar app in a group | I pick it from the group | its icon comes back, its own menu opens, and the icon hides again once the menu closes | `AC13OpenMenuBarIconTests` |
| AC-14 | a menu bar app in a group that is not running | I pick it from the group | I am told, and the hidden icons end up hidden | `AC14MissingMenuBarIconTests` |
| AC-15 | hiding is on and an app's icon is in view | I add the app to a group, or remove it from its last one | its icon is moved behind the marker, or back into view, without me dragging anything; other icons stay where they were | `AC15ArrangeMenuBarIconsTests` |
| AC-16 | a group with items | I click its icon | a strip opens under it with one icon per item, in order; picking one closes the strip and opens the item; clicking anywhere else closes it; a right-click gives Settings and Quit | manual check in `docs/DESIGN.md` |

Test levels (see `docs/DESIGN.md`):
- **Unit** (always): domain with fakes for the ports. `swift test --package-path Core`.
- **Integration**: the JSON store against a real temporary directory (AC-7, AC-8).
- **End-to-end**: no automated UI tests in v1; the visible part (icon in the bar, dropping on
  the icon) is checked by hand with the list in `docs/DESIGN.md`. Recorded as debt.
- **Evals and performance**: not applicable (no LLM, no numbers in this spec).

## 6. Edge cases and errors
- **Group with no items:** the strip says "No items yet" and has the button to settings.
- **Empty or whitespace-only name:** the group is not created.
- **Compound emoji or unknown symbol:** the emoji is stored as is; an SF Symbol that does not
  exist on this macOS version is shown as a generic circle, without crashing.
- **Duplicate item** (same target): ignored within a group; allowed across groups.
- **App that moved to another folder:** resolved by bundle id before path.
- **Dropped thing that is not an app, file or folder** (text, an image dragged from a web
  page): ignored.
- **Many items** (more than eight): the strip wraps into more rows.
- **Item whose app is not installed:** shown in the strip with a placeholder icon.
- **No room in the menu bar** (notch): macOS hides icons on its own; Usherette does not solve
  this in v1. Fewer icons in the bar, which is what v2 is about, is what helps.
- **Display without a notch:** hiding is not offered there yet; the setting says so.
- **Hidden icon that was never seen:** an app whose icon is hidden cannot be listed until the
  icons have been shown once; the settings window says so.
- **Opening one hidden icon shows all of them** for as long as its menu is open.
- **Moving an icon takes the pointer for about a second:** Usherette makes the same ⌘-drag a
  person would, and puts the pointer back. It never starts a drag unless the icon under the
  pointer belongs to the app it means to move.
- **An icon that will not move** after three tries is named in the settings window, and the
  others are still handled.
- **App in a group whose icon is in view at launch:** it is moved behind the marker; when
  everything is already in place, nothing moves.
- **Accessibility taken away while in use:** picking a menu bar app says the permission is
  needed, and nothing is revealed.

## 7. Beyond v1
Planned capabilities, in the order of the roadmap in `HANDOFF.md`. Acceptance criteria are
written when each stage is next.

- **Organizer (the main idea).** Other apps' real menu bar items leave the main bar and show
  up in the strip of their group, where clicking one opens its own menu. This is the opt-in
  module (Accessibility). Without Screen Recording the strip shows each app's icon rather
  than a picture of its menu bar item, so a live badge on the original is not visible.
  Without the module, Usherette still hides the icons and the strip launches the apps.
  Spike #8 (`docs/spikes/0008-organizer.md`) showed this works on macOS 27.2.
- **Keyboard.** A hotkey per group, and search across everything in the groups.
- **Profiles and triggers.** Named setups ("Working", "Focus", "Gaming") that change what the
  bar shows, switched by hand, by hotkey or automatically. With the module a profile covers
  other apps' icons too; without it, only Usherette's own groups.
- **Automation.** Shortcuts actions and AppleScript.
- **Custom items.** System readings, labels, spacers.
- **File shelf.** A place to drop files temporarily and send them with AirDrop.

### Parity with the reference
Reference: **Bartender 7** and **Bartender Pro** (commercial), as described on their product
pages on 2026-11-15. Usherette builds the capabilities it wants under its own names and
design; nothing is copied.

| The reference does | Usherette | Notes |
|---|---|---|
| Combine related items into one group | **Yes, v1** | The core of Usherette; groups also hold things to launch, which the reference does not |
| Hide other apps' icons | Yes | Without permissions (spike #8) |
| Show hidden icons on demand | Opt-in module | Needs Accessibility; off by default (ADR 0003). Shown in the group's strip |
| Work without Screen Recording | Yes, always | No feature may require it (ADR 0003) |
| A bar under the menu bar holding the hidden icons | Yes, per group | Each group opens its own strip, instead of one bar for everything |
| Reach icons covered by the notch | No | Fewer icons in the bar removes the cause |
| Search and activate other apps' items from the keyboard | No | Search covers what is in Usherette's groups |
| Hotkeys | Planned | One per group |
| Search and keyboard-only use | Planned | Over the contents of the groups |
| Profiles that replace the whole bar | Planned | Own groups without permissions; other apps' icons with the module |
| Triggers | Planned | Power, displays and time need no permission; Wi-Fi and Focus need a narrow one and are opt-in each |
| Automation: Shortcuts, AppleScript, agents | Planned | |
| Custom items: system readings, labels, spacers, emoji | Planned | Built-in sources only; no custom scripts (section 3) |
| Spacing between menu bar items | Planned, to verify | A global macOS preference |
| Files and AirDrop shelf | Later | |
| Monitoring of coding agents | Later, to define | Must not read other tools' data without a clear opt-in |
| Audio controls | Later, only if feasible | Low priority. Now-playing for any app depends on a private macOS API |
| Menu bar styling (tints, gradients, shapes) | No | Not a goal |
| Clipboard history | No | Dedicated apps do it, and it means reading user data |
| Calendar | No | macOS has it, and it means reading user data |
| Weather | No | macOS has it, and it needs the network |
