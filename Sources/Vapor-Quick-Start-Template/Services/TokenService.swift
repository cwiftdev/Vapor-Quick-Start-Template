import Vapor

protocol TokenService: RequestInstanceService {
    /// Generates a signed access token (e.g. JWT) for the specified user.
    /// - Parameter user: The user entity for whom the access token will be generated.
    /// - Returns: A signed access token string that can be used for authentication.
    /// - Throws: An error if the token generation process fails.
    func generateAccessToken(user: UserEntity) throws -> String
}

struct AppTokenService: TokenService {
    private let request: Request
    init(request: Request) { self.request = request }
    
    func generateAccessToken(user: UserEntity) throws -> String {
        return try request.jwt.sign(UserPayload(with: user))
    }
}

extension Application {
    private enum TokenServiceStorageKey: StorageKey {
        typealias Value = any TokenService.Type
    }
    
    var tokenServiceType: any TokenService.Type {
        get {
            storage[TokenServiceStorageKey.self, default: AppTokenService.self]
        }
        set {
            storage[TokenServiceStorageKey.self] = newValue
        }
    }
}
