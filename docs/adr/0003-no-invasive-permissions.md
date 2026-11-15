# ADR 0003 · No Accessibility, no Screen Recording

**Date:** 2026-11-15 · **Status:** accepted

## Context
The original plan for v2 was to hide other apps' menu bar icons and show them inside a group
the way Ice and Bartender do. That technique needs the Accessibility permission (to find, move
and press other apps' items) and usually Screen Recording (to draw a copy of each icon). Both
permissions let an app see and control far more than a menu bar: the contents of other apps'
windows, their interface, the whole screen. That contradicts the principle that Usherette does not read user
data, even if the code never does it: users would have to trust it rather than verify it.

Recent macOS versions include their own setting to choose which apps may show an icon in the
menu bar (System Settings → Menu Bar → "Allow in the Menu Bar"). On macOS 27.2 that list
includes third-party apps (Teams, Claude, Maccy, Passwords, Docker and others were checked),
each with its own switch.

## Decision
**Usherette never requests Accessibility or Screen Recording.** Hiding other apps' icons is
left to macOS's own setting; Usherette's job is the grouping: giving each context one icon and
a way to reach the apps in it.

## Consequences
- Usherette cannot show another app's live icon (a status badge, for example) nor open that
  app's own menu bar menu from a group. What can be reached without permissions (opening the
  app, URL schemes, Shortcuts) is the subject of spike #8.
- The user hides icons once, by hand, in System Settings. Usherette can open that pane.
- The security promise becomes verifiable: the app has no permission that would let it read
  anything.
- Sandboxing, ruled out in ADR 0001 partly because of Accessibility, is possible again. Not
  decided here.

## Alternatives considered
- **Accessibility only, to press other apps' items:** lighter than Ice's approach, but the
  permission itself is the problem, not how much of it is used.
- **Do it like Ice/Bartender:** most complete, breaks with macOS updates and crosses the line
  above.
