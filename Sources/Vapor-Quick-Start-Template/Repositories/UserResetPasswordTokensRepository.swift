import Fluent
import Vapor

protocol UserResetPasswordTokensRepository: DatabaseRepository {
    func find(userID: UserEntity.IDValue) async throws -> UserResetPasswordTokenEntity?
    func find(token: String) async throws -> UserResetPasswordTokenEntity?
    func create(_ passwordToken: UserResetPasswordTokenEntity) async throws
    func delete(_ passwordToken: UserResetPasswordTokenEntity) async throws
    func delete(for userID: UserEntity.IDValue) async throws
}

struct UserResetPasswordTokensRepositoryImpl: UserResetPasswordTokensRepository {
    private let database: any Database
    init(database: any Database) { self.database = database }
    
    func find(userID: UserEntity.IDValue) async throws -> UserResetPasswordTokenEntity? {
        return try await UserResetPasswordTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
        
    }
    
    func find(token: String) async throws -> UserResetPasswordTokenEntity? {
        return try await UserResetPasswordTokenEntity.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func create(_ passwordToken: UserResetPasswordTokenEntity) async throws {
        try await passwordToken.save(on: database)
    }
    
    func delete(_ passwordToken: UserResetPasswordTokenEntity) async throws {
        try await passwordToken.delete(on: database)
    }
    
    func delete(for userID: UserEntity.IDValue) async throws {
        try await UserResetPasswordTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}
