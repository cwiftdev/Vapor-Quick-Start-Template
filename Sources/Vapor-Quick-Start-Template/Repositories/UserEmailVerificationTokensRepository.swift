import Vapor
import Fluent

protocol UserEmailVerificationTokensRepository: DatabaseRepository {
    func find(token: String) async throws -> UserEmailVerificationTokenEntity?
    func create(_ emailToken: UserEmailVerificationTokenEntity) async throws
    func delete(_ emailToken: UserEmailVerificationTokenEntity) async throws
    func delete(_ userId: UserEntity.IDValue) async throws
}

struct UserEmailVerificationTokensRepositoryImpl: UserEmailVerificationTokensRepository {
    private let database: any Database
    init(database: any Database) { self.database = database }
    
    func find(token: String) async throws -> UserEmailVerificationTokenEntity? {
        return try await UserEmailVerificationTokenEntity.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func create(_ emailToken: UserEmailVerificationTokenEntity) async throws {
        try await emailToken.save(on: database)
    }
    
    func delete(_ emailToken: UserEmailVerificationTokenEntity) async throws {
        try await emailToken.delete(on: database)
    }
    
    func delete(_ userId: UserEntity.IDValue) async throws {
        try await UserEmailVerificationTokenEntity.query(on: database)
            .filter(\.$user.$id == userId)
            .delete()
    }
}
