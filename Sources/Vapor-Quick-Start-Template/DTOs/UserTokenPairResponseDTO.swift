import Vapor

struct UserTokenPairResponseDTO: Content {
    let accessToken: String
    let refreshToken: String
}
