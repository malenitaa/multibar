import Testing
@testable import MultibarCore

// CA-1 · Crear grupos con ícono. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-1 · Crear grupos con ícono")
struct CA01CrearGrupoTests {
    @Test(
        "dado que no hay grupos, cuando creo Trabajo con briefcase y Tareas con ✅, entonces hay dos grupos con su nombre e ícono, en ese orden",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado un nombre vacío o solo espacios, cuando intento crear el grupo, entonces no se crea",
        .disabled("pendiente")
    )
    func escenario2() {}
}
