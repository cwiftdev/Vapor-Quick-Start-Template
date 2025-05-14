@testable import Vapor_Quick_Start_Template
import FluentKit
import XCTest

final class MockRefreshTokens: UserRefreshTokensRepository,
                               @unchecked Sendable {
    
    init(database: any Database) {}
    init() {}
    
    var createMethodParameter: UserRefreshTokenEntity?
    var createMethodCalledCount: Int = 0
    var createMethodError: (any Error)?
    func create(_ token: UserRefreshTokenEntity) async throws {
        createMethodParameter = token
        createMethodCalledCount += 1
        if let createMethodError {
            throw createMethodError
        }
    }
    
    var findWithIdMethodParameter: UserRefreshTokenEntity.IDValue?
    var findWithIdMethodCalledCount: Int = 0
    var findWithIdMethodError: (any Error)?
    var findWithIdMethodStubbedResult: UserRefreshTokenEntity?
    func find(id: UserRefreshTokenEntity.IDValue?) async throws -> UserRefreshTokenEntity? {
        findWithIdMethodParameter = id
        findWithIdMethodCalledCount += 1
        if let findWithIdMethodError {
            throw findWithIdMethodError
        }
        return findWithIdMethodStubbedResult
    }
    
    var findWithTokenMethodParameter: String?
    var findWithTokenMethodCalledCount: Int = 0
    var findWithTokenMethodError: (any Error)?
    var findWithTokenMethodStubbedResult: UserRefreshTokenEntity?
    func find(token: String) async throws -> UserRefreshTokenEntity? {
        findWithTokenMethodParameter = token
        findWithTokenMethodCalledCount += 1
        if let findWithTokenMethodError {
            throw findWithTokenMethodError
        }
        return findWithTokenMethodStubbedResult
    }
    
    var deleteMethodParameter: UserRefreshTokenEntity?
    var deleteMethodCalledCount: Int = 0
    var deleteMethodError: (any Error)?
    func delete(_ token: UserRefreshTokenEntity) async throws {
        deleteMethodParameter = token
        deleteMethodCalledCount += 1
        if let deleteMethodError {
            throw deleteMethodError
        }
    }
    
    var deleteWithUserIdMethodParameter: UserEntity.IDValue?
    var deleteWithUserIdMethodCalledCount: Int = 0
    var deleteWithUserIdMethodError: (any Error)?
    func delete(for userID: UserEntity.IDValue) async throws {
        deleteWithUserIdMethodParameter = userID
        deleteWithUserIdMethodCalledCount += 1
        if let deleteWithUserIdMethodError {
            throw deleteWithUserIdMethodError
        }
    }
}
