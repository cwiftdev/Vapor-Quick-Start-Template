import Fluent

struct CreateUserEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserEntity.schema)
            .field("id", .int, .identifier(auto: true))
            .field("email", .string, .required)
            .unique(on: "email")
            .field("password_hash", .string, .required)
            .field("role", .int, .required)
            .field("is_email_verified", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserEntity.schema).delete()
    }
}
