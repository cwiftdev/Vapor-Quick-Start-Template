@testable import Vapor_Quick_Start_Template
import FluentKit
import XCTest

final class MockResetPasswordTokens: UserResetPasswordTokensRepository,
                                     @unchecked Sendable {
    init(database: any Database) {}
    init() {}
    
    var findMethodParameter: UserEntity.IDValue?
    var findMethodCalledCount: Int = 0
    var findMethodError: (any Error)?
    var findMethodStubbedResult: UserResetPasswordTokenEntity?
    func find(userID: UserEntity.IDValue) async throws -> UserResetPasswordTokenEntity? {
        findMethodParameter = userID
        findMethodCalledCount += 1
        if let findMethodError {
            throw findMethodError
        }
        return findMethodStubbedResult
    }
    
    var findWithTokenMethodParameter: String?
    var findWithTokenMethodCalledCount: Int = 0
    var findWithTokenMethodError: (any Error)?
    var findWithTokenMethodStubbedResult: UserResetPasswordTokenEntity?
    func find(token: String) async throws -> UserResetPasswordTokenEntity? {
        findWithTokenMethodParameter = token
        findWithTokenMethodCalledCount += 1
        if let findWithTokenMethodError {
            throw findWithTokenMethodError
        }
        return findWithTokenMethodStubbedResult
    }
    
    var createMethodParameter: UserResetPasswordTokenEntity?
    var createMethodCalledCount: Int = 0
    var createMethodError: (any Error)?
    func create(_ passwordToken: UserResetPasswordTokenEntity) async throws {
        createMethodParameter = passwordToken
        createMethodCalledCount += 1
        if let createMethodError {
            throw createMethodError
        }
    }
    
    var deleteMethodParameter: UserResetPasswordTokenEntity?
    var deleteMethodCalledCount: Int = 0
    var deleteMethodError: (any Error)?
    func delete(_ passwordToken: UserResetPasswordTokenEntity) async throws {
        deleteMethodParameter = passwordToken
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

