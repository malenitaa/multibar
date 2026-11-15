import AppKit
import UsheretteCore

/// Keeps one menu bar icon per group. A click opens the group's strip; a right-click opens a
/// small menu with the settings window and Quit.
@MainActor
final class MenuBarController: NSObject {
    private var statusItems: [NSStatusItem] = []
    /// The groups the current status items were made for, in configuration order.
    private var groups: [Group] = []
    private let strip = GroupStripController()
    private let openSettings: () -> Void
    private let openItem: (Item) -> Void

    init(openSettings: @escaping () -> Void, openItem: @escaping (Item) -> Void) {
        self.openSettings = openSettings
        self.openItem = openItem
    }

    func show(_ groups: [Group]) {
        strip.close()
        let sameGroups = groups.map(\.id) == self.groups.map(\.id)
        self.groups = groups

        // Same groups in the same order: only what they show changed. Recreating the status
        // items would make the whole bar shuffle for nothing.
        if sameGroups {
            for (item, group) in zip(statusItems, groups.reversed()) {
                configure(item, for: group)
            }
            return
        }

        for item in statusItems {
            NSStatusBar.system.removeStatusItem(item)
        }
        keepNewGroupsVisible(groups)
        // macOS places each new status item to the left of the previous ones, so going through
        // the groups backwards makes the bar read in the order of the configuration.
        statusItems = groups.reversed().map(makeStatusItem)
    }

    /// A status item macOS has not seen before goes to the left end of the bar, which is the
    /// side the marker hides. Seeding a small position sends a new group to the right end
    /// instead. macOS only reads this the first time it sees a name; after that it remembers
    /// where the user left the icon.
    private func keepNewGroupsVisible(_ groups: [Group]) {
        let defaults = UserDefaults.standard
        for (index, group) in groups.enumerated() where defaults.object(forKey: Self.positionKey(group)) == nil {
            defaults.set(Double(groups.count - index), forKey: Self.positionKey(group))
        }
    }

    /// Where AppKit looks for a status item's first place in the bar: larger is further left.
    private static func positionKey(_ group: Group) -> String {
        "NSStatusItem Preferred Position \(autosaveName(group))"
    }

    private static func autosaveName(_ group: Group) -> String {
        "group-\(group.id.uuidString)"
    }

    private func makeStatusItem(for group: Group) -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = Self.autosaveName(group)
        if let button = item.button {
            button.target = self
            button.action = #selector(clicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        configure(item, for: group)
        return item
    }

    private func configure(_ item: NSStatusItem, for group: Group) {
        guard let button = item.button else { return }
        if let image = group.icon.symbolImage(accessibilityDescription: group.name) {
            image.isTemplate = true
            button.image = image
            button.title = ""
        } else {
            button.image = nil
            button.title = group.icon.value
        }
        button.toolTip = group.name
        button.setAccessibilityLabel(group.name)
        button.identifier = NSUserInterfaceItemIdentifier(group.id.uuidString)
    }

    @objc private func clicked(_ sender: NSStatusBarButton) {
        guard let group = groups.first(where: { $0.id.uuidString == sender.identifier?.rawValue }),
            let item = statusItems.first(where: { $0.button === sender })
        else { return }

        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            strip.close()
            showMenu(for: group, from: item)
        } else if let anchor = sender.window?.frame {
            strip.toggle(group, under: anchor, on: sender.window?.screen, openItem: openItem, openSettings: openSettings)
        }
    }

    /// Shows the menu the way a status item normally would, then takes it off again so the
    /// next plain click goes back to the strip.
    private func showMenu(for group: Group, from item: NSStatusItem) {
        let menu = NSMenu()
        let title = NSMenuItem(title: group.name, action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Settings…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        menu.addItem(NSMenuItem(title: "Quit Usherette", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }

    @objc private func showSettings() {
        openSettings()
    }
}
