import Vapor
import Fluent

protocol UserRefreshTokensRepository: DatabaseRepository {
    func create(_ token: UserRefreshTokenEntity) async throws
    func find(id: UserRefreshTokenEntity.IDValue?) async throws -> UserRefreshTokenEntity?
    func find(token: String) async throws -> UserRefreshTokenEntity?
    func delete(_ token: UserRefreshTokenEntity) async throws
    func delete(for userID: UserEntity.IDValue) async throws
}

struct UserRefreshTokensRepositoryImpl: UserRefreshTokensRepository {
    private let database: any Database
    
    init(database: any Database) {
        self.database = database
    }
    
    func create(_ token: UserRefreshTokenEntity) async throws {
        try await token.save(on: database)
    }
    
    func find(id: UserRefreshTokenEntity.IDValue?) async throws -> UserRefreshTokenEntity? {
        return try await UserRefreshTokenEntity.find(id, on: database)
    }
    
    func find(token: String) async throws -> UserRefreshTokenEntity? {
        let queryBuilder = UserRefreshTokenEntity.query(on: database)
        
        return try await queryBuilder.with(\.$user)
            .filter(\.$token == token)
            .first()
    }
    
    func delete(_ token: UserRefreshTokenEntity) async throws {
        try await token.delete(on: database)
    }
    
    func delete(for userID: UserEntity.IDValue) async throws {
        try await UserRefreshTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}

