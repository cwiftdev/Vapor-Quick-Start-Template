import Vapor
import JWT

struct UserPayload: JWTPayload, Authenticatable {
    var userID: Int
    var role: UserRole
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        do {
            try self.exp.verifyNotExpired()
        } catch {
            let error = AuthenticationError.tokenExpired
            throw error
        }
    }
    
    init(with user: UserEntity) throws {
        userID = try user.requireID()
        role = user.role
        exp = ExpirationClaim(value: .addTimeIntervalNow(Constants.TokenDuration.ACCESS_TOKEN))
    }
}
