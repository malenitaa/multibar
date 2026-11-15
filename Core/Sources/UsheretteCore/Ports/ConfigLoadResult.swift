/// What `ConfigStore.load()` found.
public struct ConfigLoadResult: Equatable, Sendable {
    /// Why stored content was set aside, and under which name it was kept.
    public struct Recovery: Equatable, Sendable {
        public enum Reason: Equatable, Sendable {
            /// Not a configuration this build can read.
            case unreadable
            /// Written by a build with a different format version.
            case unsupportedVersion(Int)
        }

        public var reason: Reason
        public var backupFileName: String

        public init(reason: Reason, backupFileName: String) {
            self.reason = reason
            self.backupFileName = backupFileName
        }
    }

    public var configuration: Configuration
    /// `nil` when the stored content was read normally or there was none.
    public var recovery: Recovery?

    public init(configuration: Configuration, recovery: Recovery? = nil) {
        self.configuration = configuration
        self.recovery = recovery
    }
}
