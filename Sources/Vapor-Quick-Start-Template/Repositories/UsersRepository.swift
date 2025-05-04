import Fluent
import Vapor

protocol UsersRepository: DatabaseRepository {
    func create(_ user: UserEntity) async throws
    func find(_ userId: UserEntity.IDValue) async throws -> UserEntity?
    func find(_ email: String) async throws -> UserEntity?
    func update(_ user: UserEntity) async throws
    func set<Field>(_ field: KeyPath<UserEntity, Field>,
                    to value: Field.Value,
                    for userID: UserEntity.IDValue) async throws where Field: QueryableProperty, Field.Model == UserEntity
}

struct UsersRepositoryImpl: UsersRepository {
    private let database: any Database
    init(database: any Database) { self.database = database }
    
    func create(_ user: UserEntity) async throws {
        do {
            try await user.save(on: database)
        } catch {
            if let failedConstraintDesc = error.failedConstraintDescription,
               failedConstraintDesc.contains("email") {
                throw AuthenticationError.emailAlreadyExist
            }
            throw error
        }
    }
    
    func find(_ userId: UserEntity.IDValue) async throws -> UserEntity? {
        return try await UserEntity.find(userId, on: database)
    }
    
    func find(_ email: String) async throws -> UserEntity? {
        return try await UserEntity.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    func update(_ user: UserEntity) async throws {
        try await user.update(on: database)
    }
    
    func set<Field>(
        _ field: KeyPath<UserEntity, Field>,
        to value: Field.Value,
        for userID: UserEntity.IDValue
    ) async throws where Field : FluentKit.QueryableProperty, Field.Model == UserEntity
    {
        return try await UserEntity.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }
}
