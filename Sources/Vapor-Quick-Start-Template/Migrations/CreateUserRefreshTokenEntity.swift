import Fluent

struct CreateUserRefreshTokenEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserRefreshTokenEntity.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .references(UserEntity.schema, "id", onDelete: .cascade), .required)
            .field("token", .string, .required)
            .unique(on: "token")
            .field("expires_at", .datetime)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserRefreshTokenEntity.schema).delete()
    }
}
