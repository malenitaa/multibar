# ADR 0001 · Lenguaje: Swift

**Fecha:** 13/11/2026 · **Estado:** aceptada

## Contexto
Multibar vive en la barra de menú de macOS: crea `NSStatusItem` dinámicos (uno por grupo),
recibe archivos soltados sobre ellos, abre apps con `NSWorkspace`, se registra como ítem de
inicio con `SMAppService` y, en la v2, hablaría con la API de Accesibilidad para tocar íconos
de otras apps. Corre solo en la Mac de la usuaria.

## Decisión
**Swift 6**, AppKit para la barra (los `NSStatusItem` creados y destruidos según la
configuración) y SwiftUI para la ventana de ajustes. Proyecto generado con XcodeGen
(`project.yml`), igual que ChargeCap. El dominio va en un Swift package (`Core/`) que se testea
con `swift test` sin abrir Xcode.

## Alternativas descartadas
- **Tauri (Rust + web):** sirve si tuviera que ser multiplataforma. No lo es, y los íconos
  dinámicos en la barra, el drop sobre el ícono y la v2 con Accesibilidad terminan en código
  nativo igual, con un puente de por medio.
- **SwiftUI `MenuBarExtra` solo:** cómodo para un ícono fijo, pero la cantidad de grupos la
  decide la usuaria en tiempo de ejecución y no permite registrar el ícono como destino de
  arrastre. Se usa AppKit para la barra.
- **Electron / TypeScript:** runtime pesado para una app que tiene que ocupar casi nada.
- **Python (rumps/PyObjC):** empaquetado frágil y sin camino claro para la v2.

## Consecuencias
- Se pide `xcodebuild` y `swift test` verdes en cada iteración (Swift se equivoca más con
  APIs que cambian entre versiones de macOS y con `@MainActor`).
- Target mínimo `[asumido]` macOS 15.
- Sin sandbox (`[asumido]`): abrir archivos arbitrarios con sandbox exige bookmarks por ítem,
  y la v2 con Accesibilidad no es compatible con el sandbox. No va al App Store.
