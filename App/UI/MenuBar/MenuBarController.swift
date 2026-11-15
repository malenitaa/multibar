import AppKit
import UsheretteCore

/// Keeps one menu bar icon per group.
@MainActor
final class MenuBarController: NSObject {
    private var statusItems: [NSStatusItem] = []
    private var itemsByID: [String: Item] = [:]
    private let openSettings: () -> Void
    private let openItem: (Item) -> Void

    init(openSettings: @escaping () -> Void, openItem: @escaping (Item) -> Void) {
        self.openSettings = openSettings
        self.openItem = openItem
    }

    func show(_ groups: [Group]) {
        for item in statusItems {
            NSStatusBar.system.removeStatusItem(item)
        }
        itemsByID = Dictionary(groups.flatMap(\.items).map { ($0.id.uuidString, $0) }, uniquingKeysWith: { first, _ in first })
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
            if let image = group.icon.symbolImage(accessibilityDescription: group.name) {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = group.icon.value
            }
            button.toolTip = group.name
            button.setAccessibilityLabel(group.name)
        }
        item.menu = makeMenu(for: group)
        return item
    }

    private func makeMenu(for group: Group) -> NSMenu {
        let menu = NSMenu()
        menu.addItem(disabledItem(group.name))
        if group.items.isEmpty {
            menu.addItem(disabledItem("No items yet"))
        }
        for item in group.items {
            let menuItem = NSMenuItem(title: item.name, action: #selector(open(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = item.id.uuidString
            menuItem.image = appIcon(for: item)
            menu.addItem(menuItem)
        }
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Settings…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        menu.addItem(NSMenuItem(title: "Quit Usherette", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    /// The icon of the app an item belongs to, taken from the app itself.
    private func appIcon(for item: Item) -> NSImage? {
        guard let bundleID = item.bundleID, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    @objc private func open(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String, let item = itemsByID[id] else { return }
        openItem(item)
    }

    @objc private func showSettings() {
        openSettings()
    }
}
