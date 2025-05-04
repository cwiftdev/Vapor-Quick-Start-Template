import Fluent

struct CreateUserResetPasswordTokenEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserResetPasswordTokenEntity.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .references(UserEntity.schema, "id", onDelete: .cascade), .required)
            .field("token", .string, .required)
            .unique(on: "token")
            .field("created_at", .datetime)
            .field("expires_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserResetPasswordTokenEntity.schema).delete()
    }
}
