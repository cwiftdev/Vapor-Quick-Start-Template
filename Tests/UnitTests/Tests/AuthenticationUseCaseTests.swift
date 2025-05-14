@testable import Vapor_Quick_Start_Template
import XCTest
import Vapor
import Fluent
import FluentKit
import PostgresNIO

final class AuthenticationUseCaseTests: BaseTest {
    private var sut: AuthenticationUseCase!
    private var localization: MockLocalizationService!
    private var keyService: MockKeyService!
    private var tokenService: MockTokenService!
    private var emailService: MockEmailService!
    private var refreshTokens: MockRefreshTokens!
    private var users: MockUsers!
    private var resetPasswordTokens: MockResetPasswordTokens!
    private var emailVerificationTokens: MockEmailVerificationTokens!
    
    override func setUp() async throws {
        try await super.setUp()
        users = .init()
        localization = .init()
        keyService = .init()
        emailService = .init()
        refreshTokens = .init()
        tokenService = .init()
        resetPasswordTokens = .init()
        emailVerificationTokens = .init()
        sut = .init(dSource: makeDependencySource())
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        users = nil
        localization = nil
        keyService = nil
        emailService = nil
        refreshTokens = nil
        tokenService = nil
        resetPasswordTokens = nil
        emailVerificationTokens = nil
        sut = nil
    }
    
    override func dependencies() -> TestDependencySource? {
        .init(
            _localizationService: localization,
            _emailService: emailService,
            _keyService: keyService,
            _tokenService: tokenService
        )
    }
    
    override func repositories() -> MockRepositoriesContainer? {
        .init(
            users: users,
            refreshTokens: refreshTokens,
            resetPasswordTokens: resetPasswordTokens,
            emailVerificationTokens: emailVerificationTokens
        )
    }
}

extension AuthenticationUseCaseTests {
    func test_register_InvalidEmail_ShouldThrowValidationError() async {
        let request = RegisterRequestDTO(
            email: "email",
            password: "!Abc12345.",
            confirmPassword: "!Abc12345."
        )

        do {
            try await sut.register(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(users.createMethodCalledCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(localization.calledLocalizeMethodCount, .zero)
            XCTAssertEqual(localization.calledLocalizeWithPartialMethodCount, .zero)
            return
        }
        XCTFail("Register should throw validation error when email invalid")
    }
    
    func test_register_InvalidPassword_ShouldThrowValidationError() async {
        let request = RegisterRequestDTO(
            email: "test@gmail.com",
            password: "a",
            confirmPassword: "a"
        )

        do {
            try await sut.register(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(users.createMethodCalledCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(localization.calledLocalizeMethodCount, .zero)
            XCTAssertEqual(localization.calledLocalizeWithPartialMethodCount, .zero)
            return
        }
        XCTFail("Register should throw error when password invalid")
    }
    
    func test_register_PasswordsDontMatch_ShouldThrowError() async throws {
        let request = RegisterRequestDTO(
            email: "test@gmail.com",
            password: "!A12345.",
            confirmPassword: "!Abcd12345."
        )
        do {
            try await sut.register(request: request)
        } catch {
            try error.assert(AuthenticationError.passwordsDontMatch)
            XCTAssertEqual(users.createMethodCalledCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(localization.calledLocalizeMethodCount, .zero)
            XCTAssertEqual(localization.calledLocalizeWithPartialMethodCount, .zero)
            return
        }
        XCTFail("Register should throw when passwords dont match")
    }
    
    func test_register_ValidRequest_ShouldRegisterSuccess() async throws {
        let request = RegisterRequestDTO(
            email: "test@gmail.com",
            password: "!Abc12345.",
            confirmPassword: "!Abc12345."
        )
        localization.stubbedLocalizeWithPartialMethodReturnParameter = "verification_content_localization"
        users.createMethodStubbedUserID = 1
        try await sut.register(request: request)
        
        XCTAssertEqual(users.createMethodCalledCount, 1)
        let registeredUser = try XCTUnwrap(users.createMethodParameter)
        XCTAssertEqual(registeredUser.email, "test@gmail.com")
        XCTAssertEqual(registeredUser.passwordHash, "826a19fed1d4e3dfb9b470d338318f98e06426135075ba64a5bc16be0195ce66")
        XCTAssertEqual(registeredUser.role, .user)
        
        XCTAssertEqual(emailService.calledSendMethodCount, 1)
        let sendedEmail = try XCTUnwrap(emailService.calledSendMethodParameter)
        XCTAssertEqual(sendedEmail.recipients.compactMap(\.email), ["test@gmail.com"])
        XCTAssertEqual(sendedEmail.subject, "email.verify_email.subject")
        XCTAssertEqual(sendedEmail.content, "verification_content_localization")
    }
    
    func test_register_DuplicateEmail_ShouldThrowError() async throws {
        let request = RegisterRequestDTO(
            email: "test@gmail.com",
            password: "!Abc12345.",
            confirmPassword: "!Abc12345."
        )
        localization.stubbedLocalizeWithPartialMethodReturnParameter = "verification_content_localization"
        users.createMethodError = AuthenticationError.emailAlreadyExist
        do {
            try await sut.register(request: request)
        } catch {
            try error.assert(AuthenticationError.emailAlreadyExist)
            XCTAssertEqual(users.createMethodCalledCount, 1)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(localization.calledLocalizeMethodCount, .zero)
            XCTAssertEqual(localization.calledLocalizeWithPartialMethodCount, .zero)
        }
    }
    
    func test_login_InvalidMail_ShouldThrowValidationError() async {
        let request = LoginRequestDTO(
            email: "email",
            password: "!Abc12345."
        )

        do {
            let _ = try await sut.login(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(users.findWithMailMethodCalledCount, .zero)
            return
        }
        XCTFail("Login should throw validation error when email invalid")
    }
    
    func test_login_InvalidPassword_ShouldThrowValidationError() async {
        let request = LoginRequestDTO(
            email: "test@gmail.com",
            password: ""
        )

        do {
            let _ = try await sut.login(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(users.findWithMailMethodCalledCount, .zero)
            return
        }
        XCTFail("Login should throw validation error when password invalid")
    }
    
    func test_login_UserNotFound_ShouldThrowValidationError() async throws {
        let request = LoginRequestDTO(
            email: "test@gmail.com",
            password: "test"
        )

        do {
            let _ = try await sut.login(request: request)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            return
        }
        XCTFail("Login should throw error when user not found")
    }
    
    func test_login_EmailNotVerified_ShouldThrowValidationError() async throws {
        let request = LoginRequestDTO(
            email: "test@gmail.com",
            password: "test"
        )
        
        let user = UserEntity()
        user.isEmailVerified = false

        users.findWithMailMethodStubbedResult = user
        do {
            let _ = try await sut.login(request: request)
        } catch {
            try error.assert(AuthenticationError.emailIsNotVerified)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            return
        }
        XCTFail("Login should throw error when email is not verified")
    }
    
    func test_login_PasswordsDontMatch_ShouldThrowValidationError() async throws {
        let request = LoginRequestDTO(
            email: "test@gmail.com",
            password: "test"
        )
        
        let user = UserEntity()
        user.passwordHash = "notEqualPasswordHash"
        user.isEmailVerified = true

        users.findWithMailMethodStubbedResult = user
        
        do {
            let _ = try await sut.login(request: request)
        } catch {
            try error.assert(AuthenticationError.invalidPassword)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            return
        }
        XCTFail("Login should throw error when passwords dont match")
    }
    
    func test_login_ValidRequest_ShouldReturnResponse() async throws {
        let request = LoginRequestDTO(
            email: "test@gmail.com",
            password: "test"
        )
        
        let user = UserEntity()
        user.id = 1
        user.passwordHash = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
        user.isEmailVerified = true

        users.findWithMailMethodStubbedResult = user
        
        let response = try await sut.login(request: request)
        XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, 1)
        XCTAssertEqual(response.accessToken, MockTokenService.defaultTokenValue)
        XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 1)
        XCTAssertEqual(response.refreshToken, MockKeyService.defaultKey)
        XCTAssertEqual(refreshTokens.createMethodCalledCount, 1)
        XCTAssertEqual(refreshTokens.createMethodParameter?.token, MockKeyService.defaultKeyHash)
        XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
    }
    
    func test_refreshAccessToken_InvalidToken_ShouldThrowError() async {
        let request = AccessTokenRequestDTO(refreshToken: "")
        do {
            let _ = try await sut.refreshAccessToken(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(refreshTokens.findWithTokenMethodCalledCount, 0)
            XCTAssertEqual(refreshTokens.deleteMethodCalledCount, 0)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, 0)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 0)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, 0)
            return
        }
        XCTFail("Should throw error when token invalid")
    }
    
    func test_refreshAccessToken_RefreshTokenNotFound_ShouldThrowError() async throws {
        let request = AccessTokenRequestDTO(refreshToken: "test_refresh_token")
        do {
            let _ = try await sut.refreshAccessToken(request: request)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(refreshTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(refreshTokens.deleteMethodCalledCount, 0)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, 0)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 0)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, 0)
            return
        }
        XCTFail("Should throw error when token doesnt exists")
    }
    
    func test_refreshAccessToken_ExpiredToken_ShouldThrowError() async throws {
        let mockRefreshToken = UserRefreshTokenEntity()
        mockRefreshToken.token = "03e451bd5ed26b0b8bfb96c791065796457d6f21fbe53c033dd9d1ce4590f6c7"
        mockRefreshToken.expiresAt = .addTimeIntervalNow(-1000)
        refreshTokens.findWithTokenMethodStubbedResult = mockRefreshToken
        
        let request = AccessTokenRequestDTO(refreshToken: "test_refresh_token")
        do {
            let _ = try await sut.refreshAccessToken(request: request)
        } catch {
            try error.assert(AuthenticationError.tokenExpired)
            XCTAssertEqual(refreshTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(refreshTokens.deleteMethodCalledCount, 1)
            XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, 0)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 0)
            XCTAssertEqual(refreshTokens.createMethodCalledCount, 0)
            return
        }
        XCTFail("Should throw error when token doesnt exists")
    }
    
    func test_refreshAccessToken_ValidRequest_ShouldReturnResponse() async throws {
        let mockRefreshToken = UserRefreshTokenEntity()
        mockRefreshToken.token = "03e451bd5ed26b0b8bfb96c791065796457d6f21fbe53c033dd9d1ce4590f6c7"
        mockRefreshToken.expiresAt = .addTimeIntervalNow(1000)
        
        let mockUser = UserEntity()
        mockUser.id = 1
        
        mockRefreshToken.$user.value = mockUser
        refreshTokens.findWithTokenMethodStubbedResult = mockRefreshToken
        
        let request = AccessTokenRequestDTO(refreshToken: "test_refresh_token")
        let response = try await sut.refreshAccessToken(request: request)
        
        XCTAssertEqual(refreshTokens.findWithTokenMethodCalledCount, 1)
        XCTAssertEqual(refreshTokens.deleteMethodCalledCount, 1)
        XCTAssertEqual(tokenService.calledGenerateAccessTokenMethodCount, 1)
        XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 1)
        XCTAssertEqual(refreshTokens.createMethodCalledCount, 1)
        XCTAssertEqual(response.refreshToken, MockKeyService.defaultKey)
        XCTAssertEqual(response.accessToken, MockTokenService.defaultTokenValue)
    }
    
    func test_sendResetPasswordMail_InvalidEmail_ShouldThrowError() async {
        let request = SendResetPasswordMailRequestDTO(email: "a")
        do {
            try await sut.sendResetPasswordMail(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(users.findWithMailMethodCalledCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(resetPasswordTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
        }
    }
    
    func test_sendResetPasswordMail_UserNotFound_ShouldThrowError() async throws {
        let request = SendResetPasswordMailRequestDTO(email: "test@gmail.com")
        do {
            try await sut.sendResetPasswordMail(request: request)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(resetPasswordTokens.createMethodCalledCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
        }
    }
    
    func test_resetPassword_ValidRequest_ShouldReturnResponse() async throws {
        let mockUser = UserEntity()
        mockUser.id = 1
        mockUser.email = "test@gmail.com"
        users.findWithMailMethodStubbedResult = mockUser
        let request = SendResetPasswordMailRequestDTO(email: "test@gmail.com")
        
        try await sut.sendResetPasswordMail(request: request)
        
        XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
        XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 1)
        XCTAssertEqual(resetPasswordTokens.createMethodCalledCount, 1)
        XCTAssertEqual(resetPasswordTokens.createMethodParameter?.token, MockKeyService.defaultKeyHash)
        XCTAssertEqual(emailService.calledSendMethodCount, 1)
        
        let sendedEmail = try XCTUnwrap(emailService.calledSendMethodParameter)
        XCTAssertEqual(sendedEmail.recipients.compactMap(\.email), ["test@gmail.com"])
        XCTAssertEqual(sendedEmail.subject, "email.reset_password.subject")
        XCTAssertEqual(sendedEmail.content, "68a06f8269371dacfb3b1b3d0406069cd158bf0d75ab23675651a2308448acba")
    }
    
    func test_verifyResetPasswordToken_TokenNotFound_ShouldThrowError() async throws {
        let resetPasswordToken = MockKeyService.defaultKey
        do {
            try await sut.verifyResetPasswordToken(token: resetPasswordToken)
        } catch {
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
        }
    }
    
    func test_verifyResetPasswordToken_TokenExpired_ShouldThrowError() async throws {
        let resetPasswordToken = MockKeyService.defaultKey
        
        let mockResetPasswordToken = UserResetPasswordTokenEntity()
        mockResetPasswordToken.id = 1
        mockResetPasswordToken.expiresAt = .addTimeIntervalNow(-1000)
        mockResetPasswordToken.token = MockKeyService.defaultKeyHash
        
        resetPasswordTokens.findWithTokenMethodStubbedResult = mockResetPasswordToken
        
        do {
            try await sut.verifyResetPasswordToken(token: resetPasswordToken)
        } catch {
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
            try error.assert(AuthenticationError.tokenExpired)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, 1)
        }
    }
    
    func test_verifyResetPasswordToken_ValidRequest_ShouldNoThrowError() async throws {
        let resetPasswordToken = MockKeyService.defaultKey
        
        let mockResetPasswordToken = UserResetPasswordTokenEntity()
        mockResetPasswordToken.id = 1
        mockResetPasswordToken.expiresAt = .addTimeIntervalNow(1000)
        mockResetPasswordToken.token = MockKeyService.defaultKeyHash
        
        resetPasswordTokens.findWithTokenMethodStubbedResult = mockResetPasswordToken
        
        try await sut.verifyResetPasswordToken(token: resetPasswordToken)
        XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
        XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
    }
    
    func test_resetPassword_InvalidPassword_ShouldThrowError() async {
        let request = ResetPasswordRequestDTO(
            password: "",
            confirmPassword: "1234",
            token: "test_token"
        )
        do {
            try await sut.resetPassword(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_InvalidConfirmPassword_ShouldThrowError() async {
        let request = ResetPasswordRequestDTO(
            password: "1234",
            confirmPassword: "",
            token: "test_token"
        )
        do {
            try await sut.resetPassword(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_InvalidToken_ShouldThrowError() async {
        let request = ResetPasswordRequestDTO(
            password: "1234",
            confirmPassword: "",
            token: "test_token"
        )
        do {
            try await sut.resetPassword(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_PasswordsDontMatch_ShouldThrowError() async throws {
        let request = ResetPasswordRequestDTO(
            password: "123",
            confirmPassword: "1234",
            token: "test_token"
        )
        do {
            try await sut.resetPassword(request: request)
        } catch {
            try error.assert(AuthenticationError.passwordsDontMatch)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_TokenNotFound_ShouldThrowError() async throws {
        let request = ResetPasswordRequestDTO(
            password: "1234",
            confirmPassword: "1234",
            token: "test_token"
        )
    
        do {
            try await sut.resetPassword(request: request)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_TokenExpired_ShouldThrowError() async throws {
        let request = ResetPasswordRequestDTO(
            password: "1234",
            confirmPassword: "1234",
            token: "test_token"
        )
        
        let mockResetPasswordToken = UserResetPasswordTokenEntity()
        mockResetPasswordToken.id = 1
        mockResetPasswordToken.expiresAt = .addTimeIntervalNow(-1000)
        mockResetPasswordToken.token = MockKeyService.defaultKeyHash
        
        resetPasswordTokens.findWithTokenMethodStubbedResult = mockResetPasswordToken
    
        do {
            try await sut.resetPassword(request: request)
        } catch {
            try error.assert(AuthenticationError.tokenExpired)
            XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, 1)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
            XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, .zero)
        }
    }
    
    func test_resetPassword_ValidRequest_ShoulNoThrowError() async throws {
        let request = ResetPasswordRequestDTO(
            password: "1234",
            confirmPassword: "1234",
            token: "test_token"
        )
        
        let mockResetPasswordToken = UserResetPasswordTokenEntity()
        mockResetPasswordToken.id = 1
        mockResetPasswordToken.expiresAt = .addTimeIntervalNow(1000)
        mockResetPasswordToken.token = MockKeyService.defaultKeyHash
        mockResetPasswordToken.$user.id = 999
        
        resetPasswordTokens.findWithTokenMethodStubbedResult = mockResetPasswordToken
        
        try await sut.resetPassword(request: request)
        XCTAssertEqual(resetPasswordTokens.findWithTokenMethodCalledCount, 1)
        XCTAssertEqual(resetPasswordTokens.deleteMethodCalledCount, .zero)
        XCTAssertEqual(users.setMethodCalledCount, 1)
        XCTAssertEqual(users.setMethodParameter?.field, \UserEntity.$passwordHash)
        let stringValue = try XCTUnwrap(users.setMethodParameter?.value as? String)
        XCTAssertEqual(stringValue, "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4")
        XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodCalledCount, 1)
        XCTAssertEqual(resetPasswordTokens.deleteWithUserIdMethodParameter, 999)
    }
    
    func test_sendEmailVerification_InvalidEmail_ShouldThrowError() async {
        let request = SendEmailVerificationRequestDTO(email: "test")
        
        do {
            try await sut.sendEmailVerification(request: request)
        } catch {
            XCTAssertTrue(error is ValidationsError)
            XCTAssertEqual(users.findWithMailMethodCalledCount, .zero)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
        }
    }
    
    func test_sendEmailVerification_UserNotFound_ShouldThrowError() async throws {
        let request = SendEmailVerificationRequestDTO(email: "test@gmail.com")
        
        do {
            try await sut.sendEmailVerification(request: request)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
        }
    }
    
    func test_sendEmailVerification_EmailAlreadyVerified_ShouldThrowError() async throws {
        let request = SendEmailVerificationRequestDTO(email: "test@gmail.com")
        
        let mockUser = UserEntity()
        mockUser.id = 1
        mockUser.isEmailVerified = true
        users.findWithMailMethodStubbedResult = mockUser

        do {
            try await sut.sendEmailVerification(request: request)
        } catch {
            try error.assert(AuthenticationError.emailAlreadyVerified)
            XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
            XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, .zero)
            XCTAssertEqual(emailService.calledSendMethodCount, .zero)
        }
    }
    
    func test_sendEmailVerification_ValidRequest_ShouldNoThrowError() async throws {
        let request = SendEmailVerificationRequestDTO(email: "test@gmail.com")
        
        let mockUser = UserEntity()
        mockUser.id = 1
        mockUser.isEmailVerified = false
        users.findWithMailMethodStubbedResult = mockUser

        try await sut.sendEmailVerification(request: request)
        XCTAssertEqual(users.findWithMailMethodCalledCount, 1)
        XCTAssertEqual(keyService.calledGenerateUniqueKeyCount, 1)
        XCTAssertEqual(emailService.calledSendMethodCount, 1)
    }
    
    func test_verifyEmailVerificationToken_TokenNotFound_ShouldThrowError() async throws {
        let token = MockKeyService.defaultKey
        
        do {
            try await sut.verifyEmailVerificationToken(token: token)
        } catch {
            try error.assert(AuthenticationError.userNotFound)
            XCTAssertEqual(emailVerificationTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(emailVerificationTokens.findWithTokenMethodParameter, MockKeyService.defaultKeyHash)
            XCTAssertEqual(emailVerificationTokens.deleteMethodCalledCount, .zero)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
        }
    }
    
    func test_verifyEmailVerificationToken_TokenExpired_ShouldThrowError() async throws {
        let token = MockKeyService.defaultKey
        
        let mockToken = UserEmailVerificationTokenEntity()
        mockToken.id = 1
        mockToken.expiresAt = .addTimeIntervalNow(-1000)
        mockToken.token = MockKeyService.defaultKeyHash
        emailVerificationTokens.findWithTokenMethodStubbedResult = mockToken
        
        do {
            try await sut.verifyEmailVerificationToken(token: token)
        } catch {
            try error.assert(AuthenticationError.tokenExpired)
            XCTAssertEqual(emailVerificationTokens.findWithTokenMethodCalledCount, 1)
            XCTAssertEqual(emailVerificationTokens.findWithTokenMethodParameter, MockKeyService.defaultKeyHash)
            XCTAssertEqual(emailVerificationTokens.deleteMethodCalledCount, 1)
            XCTAssertEqual(emailVerificationTokens.deleteMethodParameter?.id, 1)
            XCTAssertEqual(users.setMethodCalledCount, .zero)
        }
    }
    
    func test_verifyEmailVerificationToken_ValidRequest_ShouldNoThrowError() async throws {
        let token = MockKeyService.defaultKey
        
        let mockToken = UserEmailVerificationTokenEntity()
        mockToken.id = 1
        mockToken.expiresAt = .addTimeIntervalNow(1000)
        mockToken.token = MockKeyService.defaultKeyHash
        mockToken.$user.id = 999
        emailVerificationTokens.findWithTokenMethodStubbedResult = mockToken
        try await sut.verifyEmailVerificationToken(token: token)
        XCTAssertEqual(emailVerificationTokens.findWithTokenMethodCalledCount, 1)
        XCTAssertEqual(emailVerificationTokens.findWithTokenMethodParameter, MockKeyService.defaultKeyHash)
        XCTAssertEqual(emailVerificationTokens.deleteWithUserIdMethodCalledCount, 1)
        XCTAssertEqual(emailVerificationTokens.deleteWithUserIdMethodParameter, 999)
        XCTAssertEqual(users.setMethodCalledCount, 1)
        XCTAssertEqual(users.setMethodParameter?.field, \UserEntity.$isEmailVerified)
        XCTAssertEqual(users.setMethodParameter?.userID, 999)
        let boolValue = try XCTUnwrap(users.setMethodParameter?.value as? Bool)
        XCTAssertEqual(boolValue, true)
    }
}

extension Error {
    func assert<T: Error>(_ requiredType: T) throws where T: Equatable {
        let error = try XCTUnwrap(self as? T)
        XCTAssertEqual(error, requiredType)
    }
}
