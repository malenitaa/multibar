#!/usr/bin/env bash
# Lint y formato con swift-format (viene con el toolchain de Swift 6, sin dependencias).
# Uso: ./scripts/lint.sh        → revisa
#      ./scripts/lint.sh --fix  → formatea en el lugar
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == "--fix" ]]; then
  swift format format --in-place --recursive Core/Sources Core/Tests App
else
  swift format lint --strict --recursive Core/Sources Core/Tests App
fi
# El dominio no importa frameworks de UI ni del sistema (ADR 0002).
if grep -rEn "import (AppKit|SwiftUI|ServiceManagement|ApplicationServices)" Core/Sources; then
  echo "error: Core/Sources importa un framework que no corresponde (ADR 0002)" >&2
  exit 1
fi
