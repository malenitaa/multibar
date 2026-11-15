import AppKit
import SwiftUI
import UsheretteCore

/// Shows a group's strip under its icon and closes it when the user clicks anywhere else.
@MainActor
final class GroupStripController {
    private var panel: NSPanel?
    private var shownGroup: UsheretteCore.Group.ID?
    private var monitors: [Any] = []

    /// Opens the strip of `group` under `anchor` (the group icon's frame on screen), or closes
    /// it if it is the one already open.
    func toggle(
        _ group: UsheretteCore.Group,
        under anchor: NSRect,
        on screen: NSScreen?,
        openItem: @escaping (Item) -> Void,
        openSettings: @escaping () -> Void
    ) {
        let wasShowingThisGroup = shownGroup == group.id
        close()
        guard !wasShowingThisGroup else { return }

        let view = GroupStripView(
            group: group,
            openItem: { [weak self] item in
                self?.close()
                openItem(item)
            },
            openSettings: { [weak self] in
                self?.close()
                openSettings()
            }
        )
        let hosting = FirstClickHostingView(rootView: view)
        let size = hosting.fittingSize

        // Never takes focus: the app the user is working in stays in front.
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: size), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        panel.contentView = hosting
        panel.setFrameOrigin(Self.origin(for: size, under: anchor, within: (screen ?? NSScreen.main)?.visibleFrame))
        panel.orderFrontRegardless()

        self.panel = panel
        shownGroup = group.id
        watchForClicksElsewhere()
    }

    func close() {
        monitors.forEach(NSEvent.removeMonitor)
        monitors = []
        panel?.orderOut(nil)
        panel = nil
        shownGroup = nil
    }

    /// Centred under the icon, a little below the menu bar, and kept on screen.
    private static func origin(for size: NSSize, under anchor: NSRect, within visible: NSRect?) -> NSPoint {
        var x = anchor.midX - size.width / 2
        if let visible {
            x = min(max(x, visible.minX + 8), visible.maxX - size.width - 8)
        }
        return NSPoint(x: x, y: anchor.minY - size.height - 6)
    }

    private func watchForClicksElsewhere() {
        let buttons: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown]
        // Clicks in other apps. Watching mouse buttons needs no permission.
        let elsewhere = NSEvent.addGlobalMonitorForEvents(matching: buttons) { [weak self] _ in
            Task { @MainActor in self?.close() }
        }
        // Clicks in our own windows, other than the strip itself and the menu bar icons, which
        // decide for themselves what a click means.
        let ours = NSEvent.addLocalMonitorForEvents(matching: buttons) { [weak self] event in
            let onMenuBarIcon = event.window?.className.contains("StatusBar") ?? false
            if let self, event.window !== self.panel, !onMenuBarIcon {
                self.close()
            }
            return event
        }
        monitors = [elsewhere, ours].compactMap { $0 }
    }
}

/// The strip is not the key window, so its buttons have to accept the click that reaches them
/// first instead of spending it on getting focus.
private final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }
}
