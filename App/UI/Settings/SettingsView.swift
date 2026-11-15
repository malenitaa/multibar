import SwiftUI
import UsheretteCore

/// Lists the groups and lets the user add one.
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

            Text("Groups").font(.headline)
            if model.configuration.groups.isEmpty {
                Text("No groups yet. Each group you add becomes an icon in the menu bar.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.configuration.groups) { group in
                        HStack(spacing: 8) {
                            GroupIconView(icon: group.icon, name: group.name)
                                .frame(width: 22)
                            Text(group.name)
                        }
                    }
                }
            }

            Divider()

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

            if let error = model.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("error-message")
            }
        }
        .padding(20)
        .frame(width: 480, alignment: .leading)
    }

    private func add() {
        if model.addGroup(name: name, iconText: iconText) {
            name = ""
            iconText = ""
        }
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
