@testable import Vapor_Quick_Start_Template
import FluentKit
import XCTest

struct MockRepositories: @unchecked Sendable {
    let container: MockRepositoriesContainer?
    init(db: any Database) { container = nil }
    init(container: MockRepositoriesContainer?) { self.container = container }
}

extension MockRepositories: RepositoryService {
    var resetPasswordTokens: any UserResetPasswordTokensRepository { unwrap(container?.resetPasswordTokens) }
    var users: any UsersRepository { unwrap(container?.users) }
    var refreshTokens: any UserRefreshTokensRepository { unwrap(container?.refreshTokens) }
    var emailVerificationTokens: any UserEmailVerificationTokensRepository { unwrap(container?.emailVerificationTokens) }
}

struct MockRepositoriesContainer {
    let users: (any UsersRepository)?
    let refreshTokens: (any UserRefreshTokensRepository)?
    let resetPasswordTokens: (any UserResetPasswordTokensRepository)?
    let emailVerificationTokens: (any UserEmailVerificationTokensRepository)?
    
    init(
        users: (any UsersRepository)? = nil,
        refreshTokens: (any UserRefreshTokensRepository)? = nil,
        resetPasswordTokens: (any UserResetPasswordTokensRepository)? = nil,
        emailVerificationTokens: (any UserEmailVerificationTokensRepository)? = nil
    ) {
        self.users = users
        self.refreshTokens = refreshTokens
        self.resetPasswordTokens = resetPasswordTokens
        self.emailVerificationTokens = emailVerificationTokens
    }
}
