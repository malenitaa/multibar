# ADR 0002 · Shape: lightweight hexagonal

**Date:** 2026-11-13 · **Status:** accepted

## Context
Ports and adapters pay off when at least two of these hold: more than one external system, a
life longer than three months, other people touching the code, logic worth testing without the
system. Here all four hold:
- **Several external systems:** `NSWorkspace` (opening), the disk (configuration),
  `SMAppService` (login item).
- **Long life:** it is a daily tool.
- **Other contributors:** the project is open source.
- **Logic testable without the system:** groups, items, duplicates, ordering, classifying what
  gets dropped, configuration migration.

## Decision
```
Core/                        Swift package, Foundation only
  Sources/MultibarCore/        domain (types and use cases) + ports (protocols)
  Sources/MultibarPersistence/ adapter: configuration as JSON
  Tests/                       one file per acceptance criterion, with fakes for the ports
App/                         Xcode target (AppKit + SwiftUI)
  Adapters/                    NSWorkspace, SMAppService, file icons
  UI/                          status items, menu, settings window
  MultibarApp.swift            composition: the only place that wires the graph
```
- One port per need of the domain (`Launcher`, `ConfigStore`, `TargetResolver`,
  `LoginItemService`), not per system.
- v2 comes in as more adapters without touching the domain.

## Verification
```bash
grep -rE "import (AppKit|SwiftUI|ServiceManagement|ApplicationServices)" Core/Sources
```
must print nothing. `./scripts/lint.sh` runs it.

## Alternatives considered
- **Simple modular (everything in the app target):** faster to start, but tests would need the
  app host and logic would get mixed with AppKit.
