import Vapor

struct AccessTokenRequestDTO: Content {
    let refreshToken: String
}

extension AccessTokenRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("refreshToken", as: String.self, is: !.empty)
    }
}
