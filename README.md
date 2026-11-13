# Multibar

Grupos propios en la barra de menú de macOS. Cada grupo es un ícono que elegís (un símbolo o un
emoji) y adentro tiene lo que quieras abrir: apps, archivos, carpetas, una VM, un atajo, una web.
Por ejemplo, un grupo "Trabajo" con Teams, Contraseñas y la VM, y otro "Tareas" con lo tuyo.

> Estado: esqueleto. Todavía no hace nada; la spec está en [SPEC.md](SPEC.md) y el plan en
> [HANDOFF.md](HANDOFF.md).

## Requisitos
- macOS 15 o posterior.
- Para compilar: Xcode 16 o posterior y [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  (`brew install xcodegen`).

## Compilar y correr
```bash
xcodegen generate
open Multibar.xcodeproj
```
El `.xcodeproj` no está en el repo: se genera desde `project.yml`. Para firmar, elegí tu equipo
en Xcode (Signing & Capabilities) o pasá `DEVELOPMENT_TEAM=<id>` a `xcodebuild`.

## Tests y lint
```bash
swift test --package-path Core
./scripts/lint.sh          # --fix para formatear
```

## Privacidad
Multibar no se conecta a internet ni manda datos. La configuración vive en
`~/Library/Application Support/Multibar/config.json`.

## Licencia
[Apache-2.0](LICENSE): podés usarlo, modificarlo y redistribuirlo, también comercialmente,
avisando qué archivos cambiaste.
