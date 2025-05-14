@testable import Vapor_Quick_Start_Template
import FluentKit
import XCTest

final class MockUsers: UsersRepository,
                       @unchecked Sendable {
    
    init(database: any Database) {}
    init() {}
    
    var createMethodParameter: UserEntity?
    var createMethodCalledCount: Int = 0
    var createMethodError: (any Error)?
    var createMethodStubbedUserID: UserEntity.IDValue?
    func create(_ user: UserEntity) async throws {
        createMethodParameter = user
        createMethodCalledCount += 1
        if let createMethodStubbedUserID {
            user.id = createMethodStubbedUserID
        }
        if let createMethodError {
            throw createMethodError
        }
    }
    
    var findWithIdMethodParameter: UserEntity.IDValue?
    var findWithIdMethodCalledCount: Int = 0
    var findWithIdMethodError: (any Error)?
    var findWithIdMethodStubbedResult: UserEntity?
    func find(_ userId: UserEntity.IDValue) async throws -> UserEntity? {
        findWithIdMethodParameter = userId
        findWithIdMethodCalledCount += 1
        if let findWithIdMethodError {
            throw findWithIdMethodError
        }
        return findWithIdMethodStubbedResult
    }
    
    var findWithMailMethodParameter: String?
    var findWithMailMethodCalledCount: Int = 0
    var findWithMailMethodError: (any Error)?
    var findWithMailMethodStubbedResult: UserEntity?
    func find(_ email: String) async throws -> UserEntity? {
        findWithMailMethodParameter = email
        findWithMailMethodCalledCount += 1
        if let findWithMailMethodError {
            throw findWithMailMethodError
        }
        return findWithMailMethodStubbedResult
    }
    
    var updateMethodParameter: UserEntity?
    var updateMethodCalledCount: Int = 0
    var updateMethodError: (any Error)?
    func update(_ user: UserEntity) async throws {
        updateMethodParameter = user
        updateMethodCalledCount += 1
        if let updateMethodError {
            throw updateMethodError
        }
    }
    
    typealias SetMethodParameters = (field: AnyKeyPath, value: Any, userID: UserEntity.IDValue)
    var setMethodParameter: SetMethodParameters?
    var setMethodCalledCount: Int = 0
    var setMethodError: (any Error)?
    func set<Field>(_ field: KeyPath<UserEntity, Field>, to value: Field.Value, for userID: UserEntity.IDValue) async throws where Field : FluentKit.QueryableProperty, Field.Model == UserEntity {
        setMethodParameter = (field, value, userID)
        setMethodCalledCount += 1
        if let setMethodError {
            throw setMethodError
        }
    }
}
