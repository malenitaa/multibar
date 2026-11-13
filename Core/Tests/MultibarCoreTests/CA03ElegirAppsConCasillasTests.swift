import Testing
@testable import MultibarCore

// CA-3 · Elegir apps con casillas. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-3 · Elegir apps con casillas")
struct CA03ElegirAppsConCasillasTests {
    @Test(
        "dado Teams en el grupo, cuando marco Contraseñas y desmarco Teams, entonces Contraseñas entra, Teams sale y el resto no cambia",
        .disabled("pendiente")
    )
    func escenario1() {}
}
