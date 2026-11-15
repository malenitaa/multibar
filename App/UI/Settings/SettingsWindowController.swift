import AppKit
import SwiftUI

/// Owns the settings window and brings it to the front.
@MainActor
final class SettingsWindowController {
    private let window: NSWindow

    init(model: AppModel) {
        window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(model: model)))
        window.title = "Usherette"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        // Shown from another desktop, the window comes to that desktop. Without this, macOS
        // switches back to the desktop the window was last on.
        window.collectionBehavior = [.moveToActiveSpace]
        window.center()
    }

    func show() {
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}
