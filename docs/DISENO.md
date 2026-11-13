# Multibar — diseño interno

**Última actualización:** 13/11/2026

## Dónde está todo
| Qué | Dónde |
|---|---|
| Dominio (grupos, ítems, casos de uso) y puertos | `Core/Sources/MultibarCore/` |
| Adaptador de configuración JSON | `Core/Sources/MultibarPersistence/` |
| Tests, uno por criterio de la SPEC | `Core/Tests/` |
| Composición (arma el grafo) | `App/MultibarApp.swift` |
| Adaptadores de sistema (`NSWorkspace`, `SMAppService`, íconos) | `App/Adapters/` (se crea con la etapa 2) |
| Barra, menú y ventana de ajustes | `App/UI/` (se crea con la etapa 2) |
| Proyecto de Xcode | se genera desde `project.yml` con `xcodegen generate` |

Regla de dependencias (ADR 0002): `App` → `MultibarPersistence` → `MultibarCore`. `Core/Sources`
no importa AppKit, SwiftUI ni ServiceManagement; `./scripts/lint.sh` lo verifica.

## Piezas técnicas previstas
- **Un `NSStatusItem` por grupo**, creado y destruido cuando cambia la configuración. El ícono
  es un `NSImage(systemSymbolName:)` o el emoji como título del botón.
- **Soltar sobre el ícono:** `NSStatusBarButton` no se subclasea; se le agrega una subvista
  transparente que implementa `NSDraggingDestination` y acepta `.fileURL`. Si no funciona
  bien, el plan B es soltar en la ventana de ajustes (ver issue de CA-2).
- **Abrir:** apps con `NSWorkspace.openApplication(at:configuration:)` resolviendo por bundle id;
  archivos, carpetas y URLs con `NSWorkspace.open(_:)`.
- **Lista de apps instaladas:** `/Applications`, `/System/Applications` y `~/Applications`.
- **Inicio de sesión:** `SMAppService.mainApp`.

## Tests
| Escalón | ¿Hay? | Detalle |
|---|---|---|
| Unitarios | Sí | Dominio con fakes de los puertos, Swift Testing |
| Integración | Sí | `MultibarPersistence` contra un directorio temporal (CA-7, CA-8) |
| End-to-end | **No (deuda)** | No hay UI tests de la barra en v1: XCUITest no maneja bien `NSStatusItem`. Se verifica a mano con la lista de abajo |
| Evals | No aplica | Sin LLM |
| Rendimiento | No aplica | La spec no tiene números |
| Vulnerabilidades de dependencias | No aplica por ahora | `Core` no tiene dependencias; Dependabot vigila si aparecen |

### Chequeo manual antes de cada release
1. Crear dos grupos: aparecen dos íconos en la barra, en orden.
2. Soltar una app de Finder sobre un ícono: aparece en el menú con su ícono.
3. Clic en el ítem: se abre la app.
4. Salir y volver a abrir Multibar: todo sigue igual.
