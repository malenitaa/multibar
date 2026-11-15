# Security

## What Multibar promises
- **No network.** Multibar does not connect to anything: no telemetry, no analytics, no update
  checks. The lint step in CI fails if the code references networking APIs.
- **No reading of your data.** It does not read the content of your windows, documents,
  clipboard or other apps' menus. It only stores what you add to a group.
- **Local, readable configuration.** A JSON file at
  `~/Library/Application Support/Multibar/config.json`, holding group names, icons and the
  paths, bundle ids or URLs of the items you added.
- **No command execution.** Items are opened through macOS (`NSWorkspace`); Multibar does not
  run shell commands.

## Permissions
| Version | Permission | Why |
|---|---|---|
| v1 (launcher groups) | None | Opening apps, files and URLs needs no special permission |
| v2 (organizer) | To be decided | Hiding and showing other apps' menu bar icons requires system permissions. Which ones, and why each is unavoidable, will be documented here and in an ADR before v2 ships. The launcher will keep working if you decline them |

Multibar is not sandboxed and is not distributed through the Mac App Store (see
`docs/adr/0001-language.md`).

## Reporting a vulnerability
Please do not open a public issue. Use GitHub's private reporting instead: go to the
[Security tab](https://github.com/malenitaa/multibar/security) and choose
**Report a vulnerability**. You should get a first answer within a week.

Only the latest release is supported with fixes.
