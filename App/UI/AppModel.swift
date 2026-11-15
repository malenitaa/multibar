import Foundation
import Observation
import UsheretteCore

/// What the menu bar and the settings window show, and the actions they can ask for.
@MainActor
@Observable
final class AppModel {
    private(set) var configuration = Configuration.empty
    /// Something the user should know about how the configuration was loaded.
    private(set) var notice: String?
    /// Why the last action did not work.
    private(set) var errorMessage: String?

    @ObservationIgnored var onGroupsChange: (() -> Void)?
    @ObservationIgnored private let store: any ConfigStore
    @ObservationIgnored private let createGroup: CreateGroup

    init(store: any ConfigStore, createGroup: CreateGroup) {
        self.store = store
        self.createGroup = createGroup
    }

    func load() {
        do {
            let result = try store.load()
            configuration = result.configuration
            if let recovery = result.recovery {
                notice = Self.describe(recovery)
            }
        } catch {
            errorMessage = "The configuration could not be read: \(error.localizedDescription)"
        }
        onGroupsChange?()
    }

    /// Returns whether the group was created; `errorMessage` says why when it was not.
    @discardableResult
    func addGroup(name: String, iconText: String) -> Bool {
        do {
            configuration = try createGroup(name: name, icon: GroupIcon(text: iconText), in: configuration)
            errorMessage = nil
            onGroupsChange?()
            return true
        } catch GroupError.emptyName {
            errorMessage = "Give the group a name."
        } catch {
            errorMessage = "The group could not be saved: \(error.localizedDescription)"
        }
        return false
    }

    private static func describe(_ recovery: ConfigLoadResult.Recovery) -> String {
        let why =
            switch recovery.reason {
            case .unreadable: "Your configuration file could not be read"
            case .unsupportedVersion(let version): "Your configuration file comes from a newer Usherette (format \(version))"
            }
        return "\(why), so Usherette started empty. Nothing was deleted: the file was kept as \(recovery.backupFileName)."
    }
}
