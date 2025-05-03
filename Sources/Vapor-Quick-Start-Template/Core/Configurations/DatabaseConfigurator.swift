import Vapor
import FluentPostgresDriver

protocol DatabaseConfigurator: Sendable {
    static func configure(application: Application) throws
}

extension Application {
    struct DatabaseConfiguratorKey: StorageKey {
        typealias Value = any DatabaseConfigurator.Type
    }
    var databaseConfigurator: any DatabaseConfigurator.Type {
        storage[DatabaseConfiguratorKey.self, default: AppDatabaseConfigurator.self]
    }
    
    func configureDatabase() throws {
        try databaseConfigurator.configure(application: self)
    }
}

enum AppDatabaseConfigurator: DatabaseConfigurator {
    static func configure(application: Application) throws {
        let databaseUrl = application.environmentConfiguration.databaseUrl
        let factory = DatabaseConfigurationFactory.postgres(
            configuration: try .init(url: databaseUrl)
        )
        application.databases.use(factory, as: .psql)
    }
}
