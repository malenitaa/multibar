import Testing
@testable import MultibarCore

// CA-2 · Arrastrar al ícono del grupo. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-2 · Arrastrar al ícono del grupo")
struct CA02ArrastrarAlGrupoTests {
    @Test(
        "dado el grupo Trabajo, cuando suelto Microsoft Teams.app, entonces queda como ítem de tipo app",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado que Teams ya está en Trabajo, cuando lo vuelvo a soltar, entonces no se duplica",
        .disabled("pendiente")
    )
    func escenario2() {}

    @Test(
        "dado algo que no es app, archivo ni carpeta, cuando lo suelto, entonces se ignora",
        .disabled("pendiente")
    )
    func escenario3() {}
}
