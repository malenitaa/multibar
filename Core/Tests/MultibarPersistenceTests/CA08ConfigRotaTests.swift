import Testing
@testable import MultibarPersistence

// CA-8 · Configuración rota. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-8 · Configuración rota")
struct CA08ConfigRotaTests {
    @Test(
        "dado un config.json con JSON inválido, cuando cargo, entonces queda una copia .bak con fecha, arranca vacía y se informa el error",
        .disabled("pendiente")
    )
    func escenario1() {}

    @Test(
        "dado un config.json de una versión desconocida, cuando cargo, entonces no se pisa y queda la copia .bak",
        .disabled("pendiente")
    )
    func escenario2() {}
}
