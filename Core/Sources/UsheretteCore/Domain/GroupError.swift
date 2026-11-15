/// Why a group could not be created or changed.
public enum GroupError: Error, Equatable, Sendable {
    case emptyName
    case unknownGroup
}
