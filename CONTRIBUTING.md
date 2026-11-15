# Contributing to Multibar

Thanks for wanting to help. Bugs, ideas and new features are all welcome.

## Before you start
- **Found a bug or have an idea?** Open an
  [issue](https://github.com/malenitaa/multibar/issues/new/choose) using the matching template.
  Search first to avoid duplicates.
- **Want to write code?** Pick an issue labelled `ready`, or open one describing what you want
  to add and wait for a quick OK before investing time. Issues labelled `good first issue` are
  a good place to start.
- **Found a vulnerability?** Do not open a public issue: follow [SECURITY.md](SECURITY.md).

## Setup
You need macOS 15 or later, Xcode 16 or later and XcodeGen (`brew install xcodegen`).

```bash
xcodegen generate
open Multibar.xcodeproj
```

## How the code is organized
`Core/` is a Swift package with the domain and persistence, Foundation only. `App/` is the
AppKit and SwiftUI layer. The reasoning is in [docs/adr/](docs/adr/) and the map of the code in
[docs/DESIGN.md](docs/DESIGN.md).

## Rules that keep Multibar trustworthy
These come from [SPEC.md](SPEC.md) §4 and are enforced by `./scripts/lint.sh`:
- **No network.** No `URLSession`, no `Network` framework, no telemetry, no update pings.
- **No reading user data.** Multibar only knows what the user put in a group.
- **No Accessibility, no Screen Recording.** Multibar never requests them (ADR 0003). Any
  other permission needs an issue and an ADR first.
- **The domain stays pure.** `Core/Sources` does not import AppKit, SwiftUI or
  ServiceManagement.
- **No new dependencies without discussion.** There are none today, on purpose.

## Workflow
1. One branch per piece of work, from `main`.
2. Tests first: each acceptance criterion in the spec has a test in `Core/Tests/`. Make the
   pending ones pass, or add a failing test for what you are fixing.
3. Before opening the pull request:
   ```bash
   ./scripts/lint.sh
   swift test --package-path Core
   ```
4. Open a pull request to `main` and fill in the template. Reference the issue with
   `Closes #N`. Keep it small: one issue, one pull request.

Code, comments, commit messages and docs are written in English.

## License
By contributing you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE).
