import SwiftUI
import UsheretteCore

/// Lists the groups and what is in them, and holds the settings for other apps' icons.
struct SettingsView: View {
    let model: AppModel
    @State private var name = ""
    @State private var iconText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let notice = model.notice {
                Label(notice, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let error = model.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("error-message")
            }

            groups
            Divider()
            newGroup
            Divider()
            OtherIconsSection(model: model)
        }
        .padding(20)
        .frame(width: 520, alignment: .leading)
        .onAppear { model.refreshMenuBarApps() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.refreshMenuBarApps()
        }
    }

    @ViewBuilder private var groups: some View {
        Text("Groups").font(.headline)
        if model.configuration.groups.isEmpty {
            Text("No groups yet. Each group you add becomes an icon in the menu bar.")
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(model.configuration.groups) { group in
                    GroupRow(model: model, group: group)
                }
            }
        }
    }

    @ViewBuilder private var newGroup: some View {
        Text("New group").font(.headline)
        HStack {
            TextField("Name", text: $name)
                .accessibilityIdentifier("group-name")
            TextField("Symbol name or emoji", text: $iconText)
                .accessibilityIdentifier("group-icon")
            Button("Add group", action: add)
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("add-group")
        }
        Text("For the icon, type an emoji or the name of an SF Symbol, such as briefcase.")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private func add() {
        if model.addGroup(name: name, iconText: iconText) {
            name = ""
            iconText = ""
        }
    }
}

/// One group: its icon and name, what it holds, and a way to add another app's icon to it.
private struct GroupRow: View {
    let model: AppModel
    let group: UsheretteCore.Group

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                GroupIconView(icon: group.icon, name: group.name)
                    .frame(width: 22)
                Text(group.name)
                Spacer()
                Menu("Add menu bar app") {
                    ForEach(addableApps) { app in
                        Button(app.name) { model.add(app, to: group) }
                    }
                }
                .fixedSize()
                .disabled(addableApps.isEmpty)
                .accessibilityIdentifier("add-app-\(group.name)")
            }
            ForEach(group.items) { item in
                HStack(spacing: 6) {
                    Text(item.name)
                        .foregroundStyle(.secondary)
                    Button("Remove") { model.remove(item, from: group) }
                        .buttonStyle(.link)
                        .accessibilityIdentifier("remove-\(group.name)-\(item.name)")
                }
                .padding(.leading, 30)
            }
        }
    }

    /// The running menu bar apps that are not in this group yet.
    private var addableApps: [MenuBarApp] {
        model.menuBarApps.filter { app in
            !group.items.contains { $0.kind == .menuBarIcon && $0.bundleID == app.bundleID }
        }
    }
}

/// Hiding other apps' icons (no permission) and reaching them from a group (Accessibility).
private struct OtherIconsSection: View {
    let model: AppModel

    var body: some View {
        Text("Other apps' icons").font(.headline)

        Toggle("Hide the icons on the left of Usherette's marker", isOn: Binding(get: { model.configuration.hidesIcons }, set: model.setHidesIcons))
            .disabled(!model.canHideIcons)
            .accessibilityIdentifier("hide-icons")
        if !model.canHideIcons {
            caption("Hiding works only on a display with a notch for now.")
        } else if model.configuration.hidesIcons {
            Toggle("Show them for now, to move icons around", isOn: Binding(get: { model.isArranging }, set: model.setArranging))
                .accessibilityIdentifier("arrange-icons")
            caption("While they are shown, hold ⌘ and drag any icon to the left of the ‹ marker to hide it, or to its right to keep it in view.")
        } else {
            caption("A small ‹ marker appears in the menu bar. Icons you drag to its left are kept out of the bar. This needs no permission.")
        }

        if model.isAccessibilityGranted {
            caption(
                "Accessibility is allowed: \(model.menuBarApps.count) apps with a menu bar icon can be added to a group, and opened from it. "
                    + "An app whose icon is hidden is listed only after the icons have been shown once."
            )
        } else {
            caption(
                "To add another app's icon to a group and open its menu from there, Usherette needs the Accessibility permission. "
                    + "It is used only to find and click menu bar icons. Everything else works without it."
            )
            Button("Allow Accessibility…", action: model.requestAccessibility)
                .accessibilityIdentifier("allow-accessibility")
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A group's icon the way the menu bar draws it.
private struct GroupIconView: View {
    let icon: GroupIcon
    let name: String

    var body: some View {
        if let image = icon.symbolImage(accessibilityDescription: name) {
            Image(nsImage: image)
        } else {
            Text(icon.value)
        }
    }
}
