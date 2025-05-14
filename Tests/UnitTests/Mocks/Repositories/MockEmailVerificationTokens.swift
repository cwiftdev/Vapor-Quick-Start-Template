@testable import Vapor_Quick_Start_Template
import FluentKit
import XCTest

final class MockEmailVerificationTokens: UserEmailVerificationTokensRepository,
                                         @unchecked Sendable {
    init(database: any Database) {}
    init() {}
    
    var findWithTokenMethodParameter: String?
    var findWithTokenMethodCalledCount: Int = 0
    var findWithTokenMethodError: (any Error)?
    var findWithTokenMethodStubbedResult: UserEmailVerificationTokenEntity?
    func find(token: String) async throws -> UserEmailVerificationTokenEntity? {
        findWithTokenMethodParameter = token
        findWithTokenMethodCalledCount += 1
        if let findWithTokenMethodError {
            throw findWithTokenMethodError
        }
        return findWithTokenMethodStubbedResult
    }
    
    var createMethodParameter: UserEmailVerificationTokenEntity?
    var createMethodCalledCount: Int = 0
    var createMethodError: (any Error)?
    func create(_ emailToken: UserEmailVerificationTokenEntity) async throws {
        createMethodParameter = emailToken
        createMethodCalledCount += 1
        if let createMethodError {
            throw createMethodError
        }
    }
    
    var deleteMethodParameter: UserEmailVerificationTokenEntity?
    var deleteMethodCalledCount: Int = 0
    var deleteMethodError: (any Error)?
    func delete(_ emailToken: UserEmailVerificationTokenEntity) async throws {
        deleteMethodParameter = emailToken
        deleteMethodCalledCount += 1
        if let deleteMethodError {
            throw deleteMethodError
        }
    }
    
    var deleteWithUserIdMethodParameter: UserEntity.IDValue?
    var deleteWithUserIdMethodCalledCount: Int = 0
    var deleteWithUserIdMethodError: (any Error)?
    func delete(_ userId: UserEntity.IDValue) async throws {
        deleteWithUserIdMethodParameter = userId
        deleteWithUserIdMethodCalledCount += 1
        if let deleteWithUserIdMethodError {
            throw deleteWithUserIdMethodError
        }
    }
}

