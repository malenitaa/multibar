# ADR 0002 · Forma: hexagonal liviana

**Fecha:** 13/11/2026 · **Estado:** aceptada

## Contexto
La regla de `inicio-proyecto` pide hexagonal si se cumplen dos o más de: más de un sistema
externo, vida de más de tres meses, otra persona lo toca, lógica que vale testear sin el
sistema. Acá se cumplen tres:
- **Varios sistemas externos:** `NSWorkspace` (abrir), el disco (configuración), `SMAppService`
  (inicio de sesión) y, en la v2, la API de Accesibilidad.
- **Vida larga:** es una herramienta diaria.
- **Lógica testeable sin sistema:** grupos, ítems, duplicados, orden, clasificación de lo que se
  suelta, migración de configuración.

## Decisión
```
Core/                       Swift package, solo Foundation
  Sources/MultibarCore/       dominio (tipos y casos de uso) + puertos (protocolos)
  Sources/MultibarPersistence/ adaptador: configuración en JSON
  Tests/                      un archivo por criterio de la SPEC, con fakes de los puertos
App/                        target de Xcode (AppKit + SwiftUI)
  Adapters/                   NSWorkspace, SMAppService, íconos de archivo
  UI/                         status items, menú, ventana de ajustes
  MultibarApp.swift           composición: el único lugar que arma el grafo
```
- El código va en inglés (como ChargeCap); la documentación en castellano.
- Un puerto por necesidad del dominio (`Launcher`, `ConfigStore`, `TargetResolver`,
  `LoginItemService`), no por sistema.
- La v2 entra como otro adaptador (`MenuBarExtrasProvider` o similar) sin tocar el dominio.

## Verificación
```bash
grep -rE "import (AppKit|SwiftUI|ServiceManagement|ApplicationServices)" Core/Sources
```
tiene que dar vacío.

## Alternativas descartadas
- **Simple modular (todo en el target de la app):** más rápido de arrancar, pero los tests
  necesitarían el host de la app y la lógica se mezclaría con AppKit, que es justo lo que el
  agente tiende a hacer.
