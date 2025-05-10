import Vapor

struct AuthenticationController: BaseRouteCollection {    
    typealias UseCaseType = AuthenticationUseCase
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.group("authentication") { account in
            account.post("register", use: register)
            account.post("login", use: login)
            account.post("token", use: refreshAccessToken)
            
            account.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("send", use: sendResetPasswordMail)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
                resetPasswordRoutes.put("reset", use: resetPassword)
            }

            account.group("email-verification") { emailVerificationRoutes in
                emailVerificationRoutes.post("", use: sendEmailVerification)
                emailVerificationRoutes.get("", use: verifyEmail)
            }
        }
    }
}

private extension AuthenticationController {
    @Sendable
    func register(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).register(
            request: request.content.decode(RegisterRequestDTO.self)
        )
        return .success()
    }
    
    @Sendable
    func login(request: Request) async throws -> BaseResponse<UserTokenPairResponseDTO> {
        let response = try await useCase(on: request).login(
            request: request.content.decode(LoginRequestDTO.self)
        )
        return .success(data: response)
    }
    
    @Sendable
    func refreshAccessToken(request: Request) async throws -> BaseResponse<UserTokenPairResponseDTO> {
        let response = try await useCase(on: request).refreshAccessToken(
            request: request.content.decode(AccessTokenRequestDTO.self)
        )
        return .success(data: response)
    }
    
    @Sendable
    func sendResetPasswordMail(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).sendResetPasswordMail(
            request: request.content.decode(SendResetPasswordMailRequestDTO.self)
        )
        return .success()
    }
    
    @Sendable
    func verifyResetPasswordToken(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).verifyResetPasswordToken(
            token: request.query.get(String.self, at: "token")
        )
        return .success()
    }
    
    @Sendable
    func resetPassword(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).resetPassword(
            request: request.content.decode(ResetPasswordRequestDTO.self)
        )
        return .success()
    }
    
    @Sendable
    func sendEmailVerification(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).sendEmailVerification(
            request: request.content.decode(SendEmailVerificationRequestDTO.self)
        )
        return .success()
    }
    
    @Sendable
    func verifyEmail(request: Request) async throws -> BaseResponse<EmptyResponse> {
        try await useCase(on: request).verifyEmailVerificationToken(
            token: request.query.get(String.self, at: "token")
        )
        return .success()
    }
}
