import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    try app.configureDatabase()
    try routes(app)
}
