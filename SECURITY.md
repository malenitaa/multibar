# Security

## What Usherette promises
- **No network.** Usherette does not connect to anything: no telemetry, no analytics, no update
  checks. The lint step in CI fails if the code references networking APIs.
- **No reading of your data.** It does not read the content of your windows, documents,
  clipboard or other apps' menus. It only stores what you add to a group.
- **Local, readable configuration.** A JSON file at
  `~/Library/Application Support/Usherette/config.json`, holding group names, icons and the
  paths, bundle ids or URLs of the items you added.
- **No command execution.** Items are opened through macOS (`NSWorkspace`); Usherette does not
  run shell commands.

## Permissions
| Version | Permission | Why |
|---|---|---|
| v1 (launcher groups) | None | Opening apps, files and URLs needs no special permission |
| Hiding other apps' icons | None | Done by widening a marker of Usherette's own |
| v2 (organizer), optional module | Accessibility, only if you turn the module on | Needed to list other apps' real menu bar items and open their menus from a group. Off by default; everything else works without it |
| Any version | Never Screen Recording | No feature may require it |

The rules behind this table are in `docs/adr/0003-permissions.md`. With the optional module
on, Usherette holds a permission that technically allows more than it uses; the code that
uses it is kept in one place so it can be reviewed.

Usherette is not sandboxed and is not distributed through the Mac App Store (see
`docs/adr/0001-language.md`).

## Reporting a vulnerability
Please do not open a public issue. Use GitHub's private reporting instead: go to the
[Security tab](https://github.com/malenitaa/usherette/security) and choose
**Report a vulnerability**. You should get a first answer within a week.

Only the latest release is supported with fixes.
