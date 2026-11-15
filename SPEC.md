# Multibar — specification

**Status:** draft · **Last reviewed:** 2026-11-15 · Lines marked `[assumed]` were decided
without confirmation; change the line to veto them.

## 1. What it is and who it is for
Multibar is a macOS menu bar app that organizes the menu bar **by context**. You create
**groups**: each group is its own icon in the menu bar (a symbol or emoji you pick) and holds
whatever belongs to that context. A "Work" group with Teams, Passwords and a VM; a "Tasks"
group with your clipboard manager and your assistant.

The goal is to bring together the best of the existing menu bar managers (hiding other apps'
icons) with something none of them do (grouping by category, and mixing real menu bar icons
with things to launch), while staying safe by design: no network, no telemetry, minimal
permissions.

It is built in two steps:
- **v1 — launcher groups.** Groups hold apps, files, folders and URLs to open. No special
  permissions.
- **v2 — organizer.** Groups can also hold the *real* menu bar icons of other apps, which are
  hidden from the main bar. This depends on the outcome of a spike (issue #8).

## 2. What it does (v1: launcher groups)
1. Create, rename and delete groups; each group has a name and an icon (SF Symbol or emoji) and
   shows up as an independent icon in the menu bar.
2. Add things to a group by dragging them onto its icon: apps, files, folders.
3. Add installed apps from a list with checkboxes (checked = in the group, unchecked = out).
4. Add URLs, including custom schemes: a VM (`utm://start?name=…`), a shortcut
   (`shortcuts://run-shortcut?name=…`), a website.
5. Clicking an item opens it (app, file, folder or URL).
6. Reorder and remove items and groups.
7. Remember everything across restarts.
8. Optionally launch at login.

## 3. What it does not do (on purpose)
- **v1 does not move or hide other apps' icons.** That is v2, and a spike comes first: it
  needs system permissions, relies on undocumented behaviour and can break with macOS updates.
- **It does not run shell commands.** For "anything else" there are macOS Shortcuts
  (`shortcuts://`), which the user can see and control. Running commands from a config file
  opens a door that does not need to be open.
- It does not sync between Macs and it is not on the Mac App Store (the sandbox is
  incompatible with v2).

## 4. Non-negotiable principles
Changing any of these requires an ADR.
- **No network, no telemetry.** Multibar never connects to anything. `./scripts/lint.sh` fails
  if the code references networking APIs.
- **It does not read user data.** Multibar only knows what you put in a group. It never reads
  the content of windows, documents, the clipboard or other apps' menus.
- **Minimal permissions.** v1 needs none. v2 will ask only for what the spike proves
  unavoidable, each permission justified in an ADR and in `SECURITY.md`, and the launcher keeps
  working if you decline them.
- **Your configuration is yours:** a readable JSON file at
  `~/Library/Application Support/Multibar/config.json`. A file that could not be read is never
  overwritten: a copy is kept first.
- **The domain does not import AppKit or SwiftUI** (see `docs/adr/0002-hexagonal-shape.md`).

## 5. Acceptance criteria
One per capability. Tests live in `Core/Tests/` and are currently pending.

| # | Given | When | Then | Test |
|---|---|---|---|---|
| AC-1 | there are no groups | I create "Work" with the `briefcase` icon and "Tasks" with ✅ | there are two groups with their name and icon, each with its own menu bar icon, in that order | `AC01CreateGroupTests` |
| AC-2 | the "Work" group | I drop `Microsoft Teams.app` on its icon | it becomes an item of kind app; dropping it again does not duplicate it | `AC02DropOnGroupTests` |
| AC-3 | the list of installed apps with checkboxes | I check Passwords and uncheck Teams | Passwords is in the group and Teams is out; nothing else changes | `AC03PickAppsWithCheckboxesTests` |
| AC-4 | the "Work" group | I add `utm://start?name=Windows`, a folder and a `.pdf` | they become a URL, a folder and a file, with a readable name | `AC04ItemKindsTests` |
| AC-5 | a group with an app, a file and a URL | I click each one | each opens with the method that matches its kind | `AC05OpenItemTests` |
| AC-6 | a group with three items, and two groups | I move the third item to the top, remove one and move a group | the new order is kept and what was removed does not come back | `AC06ReorderAndRemoveTests` |
| AC-7 | two groups with items | I quit and reopen Multibar | they are the same: groups, icons, items and order | `AC07PersistenceTests` |
| AC-8 | a broken `config.json`, or one from an unknown version | I open Multibar | it is not overwritten: a copy `config.json.bak-<date>` is kept, the app starts empty and says so | `AC08BrokenConfigTests` |
| AC-9 | an item whose app or file no longer exists | I open the group | the item shows up disabled as "not found" and nothing crashes | `AC09MissingTargetTests` |
| AC-10 | the "Launch at login" option | I turn it on and off | Multibar is registered and unregistered as a login item | `AC10LaunchAtLoginTests` |

Test levels (see `docs/DESIGN.md`):
- **Unit** (always): domain with fakes for the ports. `swift test --package-path Core`.
- **Integration**: the JSON store against a real temporary directory (AC-7, AC-8).
- **End-to-end**: no automated UI tests in v1; the visible part (icon in the bar, dropping on
  the icon) is checked by hand with the list in `docs/DESIGN.md`. Recorded as debt.
- **Evals and performance**: not applicable (no LLM, no numbers in this spec).

## 6. Edge cases and errors
- **Group with no items:** the menu shows "Drop something here" and a link to settings.
- **Empty or whitespace-only name:** the group is not created.
- **Compound emoji or unknown symbol:** the emoji is stored as is; an SF Symbol that does not
  exist on this macOS version is shown as a generic circle, without crashing.
- **Duplicate item** (same target): ignored within a group; allowed across groups.
- **App that moved to another folder:** resolved by bundle id before path.
- **Dropped thing that is not an app, file or folder** (text, an image dragged from a web
  page): ignored.
- **Many items** (more than 30 in a group): the menu scrolls like any `NSMenu`.
- **No room in the menu bar** (notch): macOS hides icons on its own; Multibar does not solve
  this in v1. It is exactly what v2 improves.

## 7. Out of scope for now
- **v2 — real icons of other apps inside a group** (Teams, Claude, Maccy with their status and
  their own menu), hidden from the main bar. Spike first; its acceptance criteria are written
  once the spike closes.
- A keyboard shortcut per group.
- Import and export of the configuration.

### Parity with the references (for v2)
References: **Ice** (open source, GPL-3.0: we read how it behaves, we do not copy code) and
**Bartender** (commercial).

| The reference does | Multibar? | Why |
|---|---|---|
| Hide other apps' icons from the menu bar | v2, if the spike allows | Half of the original idea; needs system permissions |
| Show them in a secondary bar | v2, inside the group | The group *is* that bar |
| Sections by visibility (visible / hidden / always hidden) | No | Multibar groups by context, not by visibility |
| Reorder other apps' icons in the bar | No | macOS already does this with ⌘-drag |
| Reveal hidden icons on hover or with a hotkey | Maybe, after v2 | Depends on the spike |
| Launcher for apps, files and URLs per group | **Yes, v1** | Neither does it; it is what makes Multibar different |
