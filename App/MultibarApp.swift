import AppKit

// Composición: el único lugar que arma adaptadores y casos de uso (ADR 0002).
// Esqueleto: la app arranca sin íconos hasta que se implemente CA-1.
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
