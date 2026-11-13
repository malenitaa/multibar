import Testing
@testable import MultibarPersistence

// CA-7 · Persistencia. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-7 · Persistencia")
struct CA07PersistenciaTests {
    @Test(
        "dado dos grupos con ítems, cuando guardo y vuelvo a cargar desde un directorio temporal, entonces grupos, íconos, ítems y orden son iguales",
        .disabled("pendiente")
    )
    func escenario1() {}
}
