import Testing
@testable import MultibarCore

// CA-6 · Reordenar y quitar. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-6 · Reordenar y quitar")
struct CA06ReordenarYQuitarTests {
    @Test(
        "dado un grupo con tres ítems, cuando muevo el tercero arriba, entonces el orden nuevo se respeta",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado un grupo con tres ítems, cuando quito uno, entonces no vuelve",
        .disabled("pendiente")
    )
    func escenario2() {}

    @Test(
        "dado dos grupos, cuando muevo el segundo antes del primero, entonces la barra respeta ese orden",
        .disabled("pendiente")
    )
    func escenario3() {}
}
