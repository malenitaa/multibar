# Spike #8 · Organizer: what works, with which permissions

**Date:** 2026-11-15 · **Tested on:** macOS 27.2, 14" MacBook with a notch (1512 pt wide), one
display · **Not tested:** macOS 26 and 15, external displays, Teams, Docker, Discord (not
running during the spike)

Throwaway command-line prototypes, run from a process that already held the Accessibility
permission. No Screen Recording API was used.

## Answer in one paragraph
The main idea is possible with Accessibility alone. Hiding other apps' icons needs **no
permission**: widening one of our own status items pushes the icons on its left out of the
bar. Listing other apps' icons and opening their menus needs **Accessibility**. A hidden icon
cannot be pressed while hidden, so the working cycle is reveal → press → hide again, which
took about 140 ms to reveal. What is fragile is the hiding width, and what is still unknown
is moving icons programmatically.

## Results
| # | Question | Result |
|---|---|---|
| 1 | Can other apps' icons be seen with no permission? | **No.** On 27.2 the window list no longer has one window per menu bar item; the bar is drawn by `MenuBarAgent` and the window server. There is nothing to enumerate without Accessibility |
| 2 | Can they be listed with Accessibility? | **Yes** for items made with `NSStatusItem`: each running app exposes them under its `AXExtrasMenuBar` attribute, with position, size and an `AXPress` action. Seen: Maccy, Passwords, the input menu, a third-party tray app. Apple's own modules (Wi-Fi, battery, clock) live in `MenuBarAgent` as plain groups with no press action |
| 3 | Does `AXPress` open the other app's menu? | **Yes** for Maccy: its panel opened under its icon and closed with Escape. For Passwords the call returned success but no window was detected within a second: inconclusive |
| 4 | Can icons be hidden with no permission? | **Yes, within limits.** A status item of our own, widened, pushes the icons on its left. At 100 pt they slide left; at 300–600 pt they leave the bar entirely (their Accessibility element disappears); at 900 pt and more macOS evicts *our* item instead and nothing is hidden. The right width depends on the display, the notch and the front app's menus, so it has to be computed, not hard-coded |
| 5 | Can a hidden icon be pressed? | **No.** While hidden it has no Accessibility element. Narrowing our item brings it back in about 140 ms, after which `AXPress` works and the menu opens at the icon's place in the bar. Widening again hides it |
| 6 | Can an icon disabled in System Settings → Menu Bar → "Allow in the Menu Bar" be reached? | **No.** An app switched off there (Claude, during the test) exposes no menu bar item at all. That setting is for icons you never want, not for icons you want inside a group |

## What this means for the design
- **Hiding** is done by a separator item that Usherette owns. No permission, but the user (or
  Usherette, see below) has to place the icons to hide on its left.
- **The strip** of a group shows app icons (taken from the app bundle, no permission). With
  the optional module, clicking one reveals the real item, presses it and hides it again when
  its menu closes. The menu appears under the real icon in the bar, not under the strip.
- **Without the module**, the strip can still hide icons and launch the apps; it cannot open
  their menus.
- **Profiles** that change which of *our* groups are shown need nothing. A profile that shows
  a different subset of other apps' icons in the bar needs to move icons across the separator.

## Still open
- **Moving icons programmatically** (so the user does not have to ⌘-drag them next to the
  separator, and so profiles can change which ones are visible). Existing managers do it with
  synthetic ⌘-drag events; not tested here.
- **Computing the hiding width** reliably across displays, with and without a notch.
- **Teams, Docker, Discord and other apps** end to end, and what happens to an app whose icon
  shows live status.
- **macOS 26 and 15.**

## Techniques, for whoever implements it
```swift
// List another app's menu bar items (Accessibility).
let app = AXUIElementCreateApplication(pid)
var extras: AnyObject?
AXUIElementCopyAttributeValue(app, "AXExtrasMenuBar" as CFString, &extras)
var items: AnyObject?
AXUIElementCopyAttributeValue(extras as! AXUIElement, kAXChildrenAttribute as CFString, &items)

// Open its menu (Accessibility).
AXUIElementPerformAction(item, kAXPressAction as CFString)

// Hide everything on the left of our separator (no permission).
separator.length = hidingWidth   // 300–600 pt on the test machine; too wide and macOS evicts it
separator.length = 14            // reveal
```
