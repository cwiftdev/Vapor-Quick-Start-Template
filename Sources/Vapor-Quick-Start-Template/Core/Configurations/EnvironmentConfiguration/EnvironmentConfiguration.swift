import Vapor

protocol EnvironmentConfiguration: Sendable {
    var jwksString: String { get }
    var databaseUrl: String { get }
    var redisUrl: String { get }
    var clientUrl: String { get }
    var apiUrl: String { get }
    var smtpHost: String { get }
    var smtpMail: String { get }
    var smtpPassword: String { get }
}

extension Application {
    struct EnvironmentConfigurationKey: StorageKey {
        typealias Value = EnvironmentConfiguration
    }
    var environmentConfiguration: any EnvironmentConfiguration {
        get {
            guard let config = storage[EnvironmentConfigurationKey.self] else {
                let config = AppEnvironmentConfiguration()
                storage[EnvironmentConfigurationKey.self] = config
                return config
            }
            return config
        }
    }
}
