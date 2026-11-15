/// Where the configuration is kept between launches.
public protocol ConfigStore: Sendable {
    /// Returns the stored configuration, or an empty one if there is none yet.
    ///
    /// Content that cannot be understood is never discarded: it is set aside and described in
    /// `ConfigLoadResult.recovery`. Throws only when the storage itself cannot be reached.
    func load() throws -> ConfigLoadResult

    func save(_ configuration: Configuration) throws
}
