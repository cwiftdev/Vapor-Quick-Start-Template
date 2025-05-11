@testable import Vapor_Quick_Start_Template
import Vapor

final class MockTokenService: TokenService,
                              @unchecked Sendable {
    static let defaultTokenValue = "token"
    init() {}
    init(request: Request) { }
    
    var calledGenerateAccessTokenMethodParameter: UserEntity?
    var calledGenerateAccessTokenMethodCount = 0
    func generateAccessToken(user: UserEntity) throws -> String {
        calledGenerateAccessTokenMethodParameter = user
        calledGenerateAccessTokenMethodCount += 1
        return MockTokenService.defaultTokenValue
    }
}
