import Testing
@testable import MultibarCore

// CA-9 · Destino que ya no existe. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-9 · Destino que ya no existe")
struct CA09DestinoFaltanteTests {
    @Test(
        "dado un ítem cuya app fue desinstalada, cuando abro el grupo, entonces aparece deshabilitado como no encontrado",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado una app que se movió de carpeta, cuando abro el grupo, entonces se resuelve por bundle id",
        .disabled("pendiente")
    )
    func escenario2() {}
}
