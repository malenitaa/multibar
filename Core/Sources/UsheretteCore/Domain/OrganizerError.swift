/// Why another app's menu bar icon could not be opened from a group.
public enum OrganizerError: Error, Equatable, Sendable {
    /// Accessibility has not been granted to Usherette.
    case permissionMissing
    /// The app is not running, or shows no icon in the menu bar.
    case iconNotFound
}
