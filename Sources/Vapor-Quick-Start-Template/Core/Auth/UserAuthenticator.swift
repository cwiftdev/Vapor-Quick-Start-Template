import Vapor
import JWT

struct UserAuthenticator: JWTAuthenticator {
    typealias Payload = UserPayload
    
    func authenticate(jwt: UserPayload, for request: Request) -> EventLoopFuture<Void> {         request.auth.login(jwt)
        return request.eventLoop.makeSucceededVoidFuture()
    }
}
