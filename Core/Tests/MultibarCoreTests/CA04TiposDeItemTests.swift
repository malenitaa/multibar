import Testing
@testable import MultibarCore

// CA-4 · Tipos de ítem. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-4 · Tipos de ítem")
struct CA04TiposDeItemTests {
    @Test(
        "dado el grupo Trabajo, cuando agrego utm://start?name=Windows, entonces queda como URL con nombre legible",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado el grupo Trabajo, cuando agrego una carpeta y un pdf, entonces quedan como carpeta y archivo",
        .disabled("pendiente")
    )
    func escenario2() {}
}
