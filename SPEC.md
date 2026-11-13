# Multibar — especificación

**Estado:** borrador · **Última revisión:** 13/11/2026 · Lo marcado `[asumido]` se decidió sin
confirmar; vetalo cambiando la línea.

## 1. Qué es y para quién
Multibar es una app de barra de menú de macOS que permite crear **grupos**: cada grupo es un
ícono propio en la barra (un símbolo o emoji elegido por la usuaria) que despliega una lista de
cosas para abrir. Por ejemplo, un grupo "Trabajo" con Teams, Contraseñas y una VM, y otro
"Tareas" con lo que haga falta. Es para quien tiene la barra llena y quiere ordenarla por
contexto. `[asumido]` uso personal, una sola persona, una sola Mac.

## 2. Qué hace (v1: lanzador)
1. Crear, renombrar y borrar grupos; cada grupo tiene nombre e ícono (SF Symbol o emoji) y
   aparece como un ícono independiente en la barra.
2. Agregar cosas a un grupo arrastrándolas sobre su ícono: apps, archivos, carpetas.
3. Agregar apps instaladas desde una lista con casillas (marcar = adentro, desmarcar = afuera).
4. Agregar URLs, incluidas las de esquema propio: una VM (`utm://start?name=…`), un atajo
   (`shortcuts://run-shortcut?name=…`), una web.
5. Al hacer clic en un ítem, se abre lo que corresponde (app, archivo, carpeta o URL).
6. Reordenar y quitar ítems y grupos.
7. Recordar todo entre reinicios.
8. Opcionalmente, arrancar sola al iniciar sesión.

## 3. Qué no hace (a propósito)
- **En v1 no mueve ni esconde íconos de otras apps** (el ícono propio de Teams, Claude o Maccy
  sigue en la barra). Eso es la v2 y antes hay un spike: pide permisos de Accesibilidad y
  Grabación de pantalla, depende de APIs privadas y se rompe con updates de macOS.
- **No ejecuta comandos de shell.** Para "cualquier cosa" están los Atajos de macOS
  (`shortcuts://`), que la usuaria ve y controla. Ejecutar comandos desde un archivo de
  configuración abre una puerta que no hace falta abrir.
- No sincroniza entre Macs ni va al App Store (el sandbox del App Store complica la v2).

## 4. Principios no negociables
- **Cero red y cero telemetría.** Multibar no se conecta a nada.
- **Sin permisos especiales en v1.** Ni Accesibilidad ni Grabación de pantalla hasta que un ADR
  de la v2 lo justifique.
- **La configuración es de la usuaria:** un JSON legible en
  `~/Library/Application Support/Multibar/config.json`. Nunca se pisa un archivo que no se
  pudo leer: se guarda una copia antes.
- **El dominio no importa AppKit ni SwiftUI** (ver `docs/adr/0002-forma-hexagonal.md`).

## 5. Criterios de aceptación
Uno por capacidad. Los tests están en `Core/Tests/` y hoy figuran como pendientes.

| # | Dado | Cuando | Entonces | Test |
|---|---|---|---|---|
| CA-1 | no hay grupos | creo "Trabajo" con el ícono `briefcase` y "Tareas" con ✅ | hay dos grupos con su nombre e ícono, cada uno con un ícono propio en la barra, en ese orden | `CA01CrearGrupoTests` |
| CA-2 | el grupo "Trabajo" | suelto `Microsoft Teams.app` sobre su ícono | queda como ítem de tipo app; si lo vuelvo a soltar, no se duplica | `CA02ArrastrarAlGrupoTests` |
| CA-3 | la lista de apps instaladas con casillas | marco Contraseñas y desmarco Teams | Contraseñas queda en el grupo y Teams sale; el resto no cambia | `CA03ElegirAppsConCasillasTests` |
| CA-4 | el grupo "Trabajo" | agrego `utm://start?name=Windows`, una carpeta y un `.pdf` | quedan como URL, carpeta y archivo, con nombre legible | `CA04TiposDeItemTests` |
| CA-5 | un grupo con una app, un archivo y una URL | hago clic en cada uno | se abre cada uno con el método que corresponde a su tipo | `CA05AbrirItemTests` |
| CA-6 | un grupo con tres ítems y dos grupos | muevo el tercer ítem arriba, quito uno y muevo un grupo | el orden nuevo se respeta y lo quitado no vuelve | `CA06ReordenarYQuitarTests` |
| CA-7 | dos grupos con ítems | cierro y abro Multibar | están igual: grupos, íconos, ítems y orden | `CA07PersistenciaTests` |
| CA-8 | un `config.json` roto o de una versión desconocida | abro Multibar | no se pisa: queda una copia `config.json.bak-<fecha>`, arranca vacía y avisa | `CA08ConfigRotaTests` |
| CA-9 | un ítem cuya app o archivo ya no existe | abro el grupo | el ítem aparece deshabilitado con "no encontrado" y nada se cae | `CA09DestinoFaltanteTests` |
| CA-10 | la opción "Abrir al iniciar sesión" | la activo y la desactivo | Multibar queda registrada y desregistrada como ítem de inicio | `CA10InicioDeSesionTests` |

Escalones de tests (ver `docs/DISENO.md`):
- **Unitarios** (siempre): dominio con fakes de los puertos. `swift test --package-path Core`.
- **Integración**: el almacén JSON contra un directorio temporal real (CA-7, CA-8).
- **End-to-end**: no hay UI tests automáticos en v1; la parte visible (ícono en la barra, soltar
  sobre el ícono) se verifica a mano con la lista de `docs/DISENO.md`. Queda como deuda.
- **Evals y rendimiento**: no aplican (no hay LLM ni números en la spec).

## 6. Casos borde y errores
- **Grupo sin ítems:** el menú muestra "Arrastrá algo acá" y el acceso a ajustes.
- **Nombre vacío o solo espacios:** no se crea; el ícono solo puede ser vacío si hay nombre.
- **Emoji compuesto o símbolo inexistente:** el emoji se guarda tal cual; un SF Symbol que no
  existe en esta versión de macOS se muestra como un círculo genérico, sin crashear.
- **Ítem duplicado** (mismo destino): se ignora en el mismo grupo; en grupos distintos se permite.
- **App que se movió de carpeta:** se resuelve por bundle id antes que por ruta.
- **Archivo que se soltó y no es app, archivo ni carpeta** (texto, imagen arrastrada de una
  web): se ignora.
- **Muchos ítems** (más de 30 en un grupo): el menú hace scroll como cualquier `NSMenu`.
- **La barra no tiene lugar** (notch): macOS esconde íconos de la derecha; Multibar no lo
  resuelve en v1. Es justamente lo que mejora la v2.

## 7. Fuera de alcance por ahora
- **v2 — íconos reales de otras apps adentro de un grupo** (Teams, Claude, Maccy con su estado
  y su menú). Spike primero; tabla de paridad abajo.
- Atajo de teclado por grupo.
- Importar y exportar la configuración.

### Paridad con la referencia (para la v2)
Referencias: **Ice** (código abierto, GPL-3.0: se lee su comportamiento, no se copia código) y
**Bartender** (comercial).

| Hace la referencia | ¿Multibar? | Por qué |
|---|---|---|
| Esconder íconos de otras apps de la barra | v2, si el spike da | Es la mitad de la idea original; requiere Accesibilidad y eventos sintéticos |
| Mostrarlos en una barra secundaria ("Ice Bar") | v2, adentro del grupo | Es lo que la usuaria pidió: el grupo es esa barra |
| Agrupar en secciones visibles/ocultas/siempre ocultas | No | Multibar agrupa por contexto, no por visibilidad |
| Reordenar íconos ajenos en la barra | No | macOS ya lo permite con ⌘ + arrastrar |
| Mostrar ocultos al pasar el mouse o con un atajo | Tal vez, v2+ | Depende del spike |
| Lanzador de apps/archivos/URLs por grupo | **Sí, v1** | Ninguna de las dos lo hace; es lo propio de Multibar |
