import Vapor

protocol TokenService: Sendable {
    func generateAccessToken(user: UserEntity) throws -> String
}

struct AppTokenService: TokenService {
    private let request: Request
    init(request: Request) { self.request = request }
    
    func generateAccessToken(user: UserEntity) throws -> String {
        return try request.jwt.sign(UserPayload(with: user))
    }
}
