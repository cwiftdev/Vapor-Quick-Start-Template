import Fluent

protocol RepositoryService: Sendable {
    init(db: any Database)
    var users: any UsersRepository { get }
    var refreshTokens: any UserRefreshTokensRepository { get }
    var resetPasswordTokens: any UserResetPasswordTokensRepository { get }
    var emailVerificationTokens: any UserEmailVerificationTokensRepository { get }
}

final class AppRepositoryService: @unchecked Sendable {
    private let db: any Database
    init(db: any Database) { self.db = db }
    
    private lazy var _users: UsersRepositoryImpl = { .init(database: db) }()
    private lazy var _refreshTokens: UserRefreshTokensRepositoryImpl = { .init(database: db) }()
    private lazy var _resetPasswordTokens: UserResetPasswordTokensRepositoryImpl = { .init(database: db) }()
    private lazy var _emailVerificationTokens: UserEmailVerificationTokensRepositoryImpl = { .init(database: db) }()
}

extension AppRepositoryService: RepositoryService {
    var users: any UsersRepository { _users }
    var refreshTokens: any UserRefreshTokensRepository { _refreshTokens }
    var resetPasswordTokens: any UserResetPasswordTokensRepository { _resetPasswordTokens }
    var emailVerificationTokens: any UserEmailVerificationTokensRepository { _emailVerificationTokens }
}
