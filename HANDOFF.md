# Usherette — handoff

**Status:** skeleton, spec and roadmap ready; the app builds but does nothing yet · **Last updated:** 2026-11-15
**Language:** Swift 6 (see `docs/adr/0001-language.md`) · **Shape:** lightweight hexagonal (`docs/adr/0002-hexagonal-shape.md`)
**Run:** `xcodegen generate && open Usherette.xcodeproj` · **Tests:** `swift test --package-path Core` · **Lint:** `./scripts/lint.sh` · **Deploy:** none (desktop app: manual release)

## Roadmap

```mermaid
timeline
    title Usherette
    section Done
        Stage 1 · Skeleton and spec : Swift + XcodeGen : 19 pending tests : CI : open source docs
    section v1 · Launcher groups
        Stage 2 · Foundations : spike on the organizer : persistence that survives broken files : one icon per group
        Stage 3 · Fill and use groups : drop on the icon : app checkboxes : open and not found
        Stage 4 · Polish : reorder and remove : launch at login
    section v2 · Organizer, the main idea
        Stage 5 · Organizer : real icons in the group's strip : optional module with Accessibility
        Stage 6 · First release : audit : signed build : Homebrew cask
    section Later
        Stage 7 · Keyboard : hotkey per group : search
        Stage 8 · Profiles and automation : profiles : triggers : Shortcuts and AppleScript
        Stage 9 · Custom items : system readings : labels and spacers : file shelf
```

| Stage | What it includes | Status | Criteria (SPEC) | Issues |
|---|---|---|---|---|
| 1 · Skeleton and spec | language, shape, SPEC, empty tests, CI, contributor docs | ✅ | — | — |
| 2 · Foundations | spike on the organizer, JSON config, one `NSStatusItem` per group | ⏳ | AC-1, AC-7, AC-8 | #8, #2, #1 |
| 3 · Fill and use groups | drop on the icon, URLs, checkboxes, opening | ⏳ | AC-2, AC-3, AC-4, AC-5, AC-9 | #3, #4, #5 |
| 4 · Polish | reorder, remove, launch at login | ⏳ | AC-6, AC-10 | #6, #7 |
| 5 · Organizer (v2) | opt-in module: other apps' real icons leave the bar and show in the group's strip; without it, icons hidden with macOS's own setting | ⏳ after the spike | written after the spike | #8 |
| 6 · First release | audit, docs, signed release, Homebrew cask `usherette` | ⏳ | all so far | — |
| 7 · Keyboard | hotkey per group, search across groups | ⏳ | to write | — |
| 8 · Profiles and automation | profiles, triggers, Shortcuts, AppleScript | ⏳ | to write | — |
| 9 · Custom items | system readings, labels, spacers, file shelf | ⏳ | to write | — |

What is in and out compared with the reference product is in the parity table of `SPEC.md` §7.

## What was done (latest first)
- 2026-11-15 · Scope set against Bartender 7 and Pro: parity table in the spec, roadmap
  extended to stages 6–9. ADR 0003 rewritten: no permissions by default, Accessibility only in
  an opt-in module, never Screen Recording.
- 2026-11-15 · Renamed from Multibar to Usherette (repository, app, modules, bundle id,
  configuration folder). `Core` split into `Domain/`, `UseCases/` and `Ports/`; design rules
  written in `docs/DESIGN.md`.
- 2026-11-15 · Docs, tests and templates moved to English; README as a product page;
  `CONTRIBUTING.md` and `SECURITY.md`; privacy principles added to the spec and enforced in
  lint. Private vulnerability reporting enabled on GitHub.
- 2026-11-13 · Project start: Swift + XcodeGen, `Core/` package (domain and persistence)
  separate from `App/`, SPEC with 10 criteria, one pending test per criterion, CI, Dependabot,
  license, 8 issues.

## What is next
1. #8 (spike): the gate for the main idea. Can the opt-in module move other apps' icons out
   of the bar and show them in a group's strip with Accessibility alone?
2. #2 (persistence) and #1 (groups in the bar): both `ready`, the base for everything else.

## Decisions taken (open to veto)
- **The main idea is the organizer:** a group opens a strip with other apps' real icons, and
  profiles swap what the bar shows. It depends on the opt-in module, so spike #8 decides how
  much of it is possible. If the spike says no, the first release is the launcher alone.
- **A group opens as a strip of icons** under the menu bar, not as a text menu.
- **Permissions (ADR 0003):** none by default; Accessibility only for the opt-in organizer
  module; never Screen Recording.
- **Out on purpose:** menu bar styling, a secondary bar, notch recovery, search over other
  apps' items, clipboard history, calendar, weather (SPEC §7).
- **Apache-2.0 license** (`LICENSE`, `NOTICE`, README).
- **Minimum macOS 15** (`project.yml`, `Core/Package.swift`).
- **No sandbox, not on the Mac App Store** (ADR 0001).
- **No shell commands as items and no custom scripts;** Shortcuts (`shortcuts://`) cover
  "anything else" (SPEC §3).
- **Group icon = SF Symbol or emoji;** custom images come later.
- **Docs and code in English.**
- **Name: Usherette** for the app, the executable, the repository and the future Homebrew
  cask (`usherette`); the name was free on Homebrew and GitHub on 2026-11-15.
- **Issue labels in English:** `feature`, `tech-debt`, `security`.

## To decide
- Whether to sandbox the default install (ADR 0003).
- Issues for stages 5 and 7–9 are not open yet; open them after spike #8.
- Audio controls: low priority, only if a way that does not rely on a private API turns up.

## Known debts
- No UI tests for the menu bar (end-to-end): manual check in `docs/DESIGN.md`.
- Signed and notarized release: handled in stage 5.

## Where everything is
| What | Where |
|---|---|
| Spec, criteria and parity table | `SPEC.md` |
| Decisions | `docs/adr/` |
| Internal design and design rules | `docs/DESIGN.md` |
| For users and contributors | `README.md`, `CONTRIBUTING.md`, `SECURITY.md` |
| Issues | https://github.com/malenitaa/usherette/issues |
