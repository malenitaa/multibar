import Testing
@testable import MultibarCore

// CA-5 · Abrir un ítem. Pendiente: se implementa hasta que pase (SPEC.md, sección 5).
@Suite("CA-5 · Abrir un ítem")
struct CA05AbrirItemTests {
    @Test(
        "dado un grupo con una app, un archivo y una URL, cuando hago clic en cada uno, entonces el Launcher recibe el pedido que corresponde a su tipo",
        .disabled("pendiente")
    )
    func escenario1() {}
}
