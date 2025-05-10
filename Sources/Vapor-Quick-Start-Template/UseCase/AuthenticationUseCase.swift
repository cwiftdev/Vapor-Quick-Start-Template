import Vapor

struct AuthenticationUseCase: BaseUseCase {
    private let dSource: any DependencySource
    
    init(dSource: any DependencySource) {
        self.dSource = dSource
    }
    
    func register(request: RegisterRequestDTO) async throws {
        try request.validate()
                
        guard request.password == request.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let passwordHash = request.password.hash
        let user = UserEntity(from: request, hash: passwordHash)
        
        try await dSource.repositories.users.create(user)
        
        let verificationToken = dSource.keyService.generateUniqueKey()
        let verificationTokenEntity = UserEmailVerificationTokenEntity(
            userID: try user.requireID(),
            token: verificationToken.hash
        )
        try await dSource.repositories.emailVerificationTokens.create(verificationTokenEntity)
        
        let clientUrl = dSource.config.clientUrl
        let verificationUrl = "\(clientUrl)/verificationKey?=\(verificationToken)"
        let emailVerificationTemplate = VerifyEmailMailTemplate(
            localizationService: dSource.localizationService,
            verificationURL: verificationUrl,
            receiver: user
        )
        try await dSource.emailService.send(emailVerificationTemplate)
    }
    
    func login(request: LoginRequestDTO) async throws -> UserTokenPairResponseDTO {
        try request.validate()
        
        guard let mailRelatedUser = try await dSource.repositories.users.find(request.email) else {
            throw AuthenticationError.userNotFound
        }
        
        guard mailRelatedUser.isEmailVerified else {
            throw AuthenticationError.emailIsNotVerified
        }
        
        guard request.password.hash == mailRelatedUser.passwordHash else {
            throw AuthenticationError.invalidPassword
        }
        
        let tokenPair = try generateTokenPair(user: mailRelatedUser)
        let refreshTokenEntity = UserRefreshTokenEntity(
            userID: try mailRelatedUser.requireID(),
            token: tokenPair.refreshToken.hash
        )
        try await dSource.repositories.refreshTokens.create(refreshTokenEntity)
        return tokenPair
    }
    
    func refreshAccessToken(request: AccessTokenRequestDTO) async throws -> UserTokenPairResponseDTO {
        try request.validate()
        
        let refreshTokens = dSource.repositories.refreshTokens
        
        let hashedRefreshToken = request.refreshToken.hash
        guard let refreshTokenEntity = try await refreshTokens.find(token: hashedRefreshToken) else {
            throw AuthenticationError.userNotFound
        }
        try await refreshTokens.delete(refreshTokenEntity)
        
        guard refreshTokenEntity.expiresAt > Date() else {
            throw AuthenticationError.tokenExpired
        }

        let tokenPair = try generateTokenPair(user: refreshTokenEntity.user)
        let newRefreshTokenEntity = UserRefreshTokenEntity(
            userID: try refreshTokenEntity.user.requireID(),
            token: tokenPair.refreshToken.hash
        )
        try await refreshTokens.create(newRefreshTokenEntity)
        
        return tokenPair
    }
    
    func sendResetPasswordMail(request: SendResetPasswordMailRequestDTO) async throws {
        try request.validate()
        
        guard let relatedUserEntity = try await dSource.repositories.users.find(request.email) else {
            throw AuthenticationError.userNotFound
        }
        
        let uniqueKey = dSource.keyService.generateUniqueKey()
        let passwordTokenEntity = UserResetPasswordTokenEntity(
            userID: try relatedUserEntity.requireID(),
            token: uniqueKey.hash
        )
        try await dSource.repositories.resetPasswordTokens.create(passwordTokenEntity)
        let clientUrl = dSource.config.clientUrl
        let resetPasswordUrl = "\(clientUrl)/resetPasswordKey?=\(uniqueKey)"
        let resetPasswordEmail = ResetPasswordMailTemplate(
            localizationService: dSource.localizationService,
            resetPasswordUrl: resetPasswordUrl,
            receiver: relatedUserEntity
        )
        try await dSource.emailService.send(resetPasswordEmail)
    }
    
    func verifyResetPasswordToken(token: String) async throws {
        let repository = dSource.repositories.resetPasswordTokens
        let passwordTokenEntity = try await repository.find(token: token.hash)
        guard let passwordTokenEntity else { throw AuthenticationError.userNotFound }
        
        guard passwordTokenEntity.expiresAt > Date() else {
            try await repository.delete(passwordTokenEntity)
            throw AuthenticationError.tokenExpired
        }
    }
    
    func resetPassword(request: ResetPasswordRequestDTO) async throws {
        try request.validate()
        
        guard request.password == request.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let hashedToken = request.token.hash
        let passwordTokenEntity = try await dSource.repositories.resetPasswordTokens.find(token: hashedToken)
        
        guard let passwordTokenEntity else {
            throw AuthenticationError.userNotFound
        }
        
        guard passwordTokenEntity.expiresAt > Date() else {
            try await dSource.repositories.resetPasswordTokens.delete(passwordTokenEntity)
            throw AuthenticationError.tokenExpired
        }
        
        let newPasswordHash = request.password.hash
        try await dSource.repositories.users.set(\.$passwordHash, to: newPasswordHash, for: passwordTokenEntity.$user.id)
        try await dSource.repositories.resetPasswordTokens.delete(for: passwordTokenEntity.$user.id)
    }
    
    func sendEmailVerification(request: SendEmailVerificationRequestDTO) async throws {
        try request.validate()
        
        let user = try await dSource.repositories.users.find(request.email)
        guard let user else { throw AuthenticationError.userNotFound }
        let userId = try user.requireID()
        
        guard !user.isEmailVerified else {
            throw AuthenticationError.emailAlreadyVerified
        }
        
        let verificationKey = dSource.keyService.generateUniqueKey()
        let newEmailToken = UserEmailVerificationTokenEntity(
            userID: userId,
            token: verificationKey.hash
        )
        try await dSource.repositories.emailVerificationTokens.create(newEmailToken)
        
        let clientUrl = dSource.config.clientUrl
        let verificationUrl = "\(clientUrl)/verificationKey?=\(verificationKey)"
        
        let emailVerificationTemplate = VerifyEmailMailTemplate(
            localizationService: dSource.localizationService,
            verificationURL: verificationUrl,
            receiver: user
        )
        try await dSource.emailService.send(emailVerificationTemplate)
    }
    
    func verifyEmailVerificationToken(token: String) async throws {
        let repository = dSource.repositories.emailVerificationTokens
        
        let emailTokenEntity = try await repository.find(token: token.hash)
        guard let emailTokenEntity else { throw AuthenticationError.userNotFound }
        
        guard emailTokenEntity.expiresAt > Date() else {
            try await repository.delete(emailTokenEntity)
            throw AuthenticationError.tokenExpired
        }
        let userId = emailTokenEntity.$user.id
        try await repository.delete(userId)
        
        try await dSource.repositories.users.set(
            \.$isEmailVerified,
             to: true,
             for: userId
        )
    }
}

private extension AuthenticationUseCase {
    func generateTokenPair(user: UserEntity) throws -> UserTokenPairResponseDTO {
        let accessToken = try dSource.tokenService.generateAccessToken(user: user)
        let refreshToken = dSource.keyService.generateUniqueKey()
        
        return UserTokenPairResponseDTO(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
