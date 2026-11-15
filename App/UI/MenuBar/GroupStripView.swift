import SwiftUI
import UsheretteCore

/// What a group shows when it is clicked: one icon per item, in order, and a way to settings.
struct GroupStripView: View {
    let group: UsheretteCore.Group
    let openItem: (Item) -> Void
    let openSettings: () -> Void

    /// How many icons fit in a row before the strip wraps.
    private static let perRow = 8
    private static let slot: CGFloat = 34

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if group.items.isEmpty {
                Text("No items yet")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            } else {
                let columns = Array(repeating: GridItem(.fixed(Self.slot), spacing: 2), count: min(group.items.count, Self.perRow))
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(group.items) { item in
                        StripButton(help: item.name, identifier: "strip-item-\(item.name)") {
                            openItem(item)
                        } label: {
                            ItemIconView(item: item)
                        }
                    }
                }
                .fixedSize()
            }

            Divider()
                .frame(height: 20)
            StripButton(help: "Usherette settings", identifier: "strip-settings", action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: group.items.count > Self.perRow ? 18 : 23, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: group.items.count > Self.perRow ? 18 : 23, style: .continuous)
                .strokeBorder(.primary.opacity(0.12), lineWidth: 1)
        }
        .padding(10)
    }
}

/// A square button of the strip that lights up under the pointer.
private struct StripButton<Label: View>: View {
    let help: String
    let identifier: String
    let action: () -> Void
    @ViewBuilder let label: () -> Label
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            label()
                .frame(width: 34, height: 34)
                .background(.primary.opacity(isHovered ? 0.12 : 0), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(help)
        .accessibilityLabel(help)
        .accessibilityIdentifier(identifier)
    }
}

/// The icon of the app an item belongs to, or a generic one when the app cannot be found.
private struct ItemIconView: View {
    let item: Item

    var body: some View {
        if let icon = item.appIcon {
            Image(nsImage: icon)
                .resizable()
                .interpolation(.high)
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "app.dashed")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
        }
    }
}
