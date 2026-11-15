import AppKit

// Composition: the only place that wires adapters and use cases (ADR 0002).
// Skeleton: the app starts with no icons until AC-1 is implemented.
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
