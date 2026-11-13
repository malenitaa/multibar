import Testing
@testable import MultibarCore

// CA-10 · Abrir al iniciar sesión. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-10 · Abrir al iniciar sesión")
struct CA10InicioDeSesionTests {
    @Test(
        "dado la opción apagada, cuando la activo, entonces el LoginItemService registra la app",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado la opción prendida, cuando la desactivo, entonces se desregistra",
        .disabled("pendiente")
    )
    func escenario2() {}
}
