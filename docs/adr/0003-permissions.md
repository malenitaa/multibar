# ADR 0003 · Permissions: none by default, Accessibility opt-in, never Screen Recording

**Date:** 2026-11-15 · **Status:** accepted

## Context
Menu bar managers such as Ice and Bartender hide other apps' icons and show them on demand.
That needs the Accessibility permission (to find, move and press other apps' menu bar items)
and, traditionally, Screen Recording (to draw a copy of each icon). Both let an app see and
control far more than a menu bar: the contents of other apps' windows, their interface, the
whole screen. Usherette's principle is that it does not read user data, and a promise the
user has to trust is weaker than one they can verify.

Two facts shape the decision:
- macOS has its own setting to choose which apps may show an icon in the menu bar (System
  Settings → Menu Bar → "Allow in the Menu Bar"). On macOS 27.2 the list includes third-party
  apps (Teams, Claude, Maccy, Passwords, Docker and others were checked), each with its own
  switch. It hides icons for good; it does not show them on demand.
- Screen Recording is avoidable: an app's own icon can stand in for a picture of its menu bar
  item. Bartender 7 advertises working without it.

## Decision
Three levels, each one chosen by the user:
1. **Default: no permissions.** Everything Usherette does out of the box (groups, launching,
   hotkeys, search, profiles) works without any system permission. Hiding other apps' icons is
   done with macOS's own setting, which Usherette can open.
2. **Opt-in: Accessibility, for one module only.** Showing other apps' real menu bar items
   inside a group, and hiding or revealing them on demand, lives in a separate module that is
   off by default. Turning it on is an explicit choice in settings, with a plain explanation
   of what the permission allows. Turning it off leaves everything else working.
3. **Never: Screen Recording.** No feature may require it.

Narrow permissions that some future features need (for example Automation for a single app,
or Focus status) follow the same rule as level 2: off by default, one switch per feature,
explained before the system prompt appears.

## Consequences
- The default install can make a verifiable promise: it holds no permission that would let it
  read anything.
- With the module on, the user is trusting the code. It is open source and the module is
  isolated behind a port, so what it does with the permission can be read in one place.
- Code that uses Accessibility lives only in the module's adapter; `./scripts/lint.sh` will
  check that nothing else imports it once the module exists.
- Spike #8 (`docs/spikes/0008-organizer.md`) showed on macOS 27.2 that the module can do its
  job with Accessibility alone, and that hiding icons needs no permission at all. If a later
  macOS breaks that, the answer is to drop the module, not to add Screen Recording.
- macOS's own "Allow in the Menu Bar" setting removes an icon completely; an app switched off
  there cannot be reached from a group. It is for icons the user never wants.
- Sandboxing stays possible for the default install; not decided here.

## Alternatives considered
- **Never request Accessibility:** the strongest promise, but it rules out showing other
  apps' icons inside a group, which is the original idea of the project.
- **Require Accessibility for everyone, like the existing managers:** simpler to build, and
  makes every user pay the trust cost for a feature they may not want.
