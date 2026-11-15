#!/usr/bin/env bash
# Lint and format with swift-format (ships with the Swift 6 toolchain, no dependencies).
# Usage: ./scripts/lint.sh        → check
#        ./scripts/lint.sh --fix  → format in place
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == "--fix" ]]; then
  swift format format --in-place --recursive Core/Sources Core/Tests App
else
  swift format lint --strict --recursive Core/Sources Core/Tests App
fi
# The domain does not import UI or system frameworks (ADR 0002).
if grep -rEn "import (AppKit|SwiftUI|ServiceManagement|ApplicationServices)" Core/Sources; then
  echo "error: Core/Sources imports a framework it must not depend on (ADR 0002)" >&2
  exit 1
fi
# Usherette never talks to the network (SPEC.md, section 4).
if grep -rEn "URLSession|NWConnection|CFNetwork|import Network" Core/Sources App; then
  echo "error: networking API referenced; Usherette must not connect to anything (SPEC.md §4)" >&2
  exit 1
fi
