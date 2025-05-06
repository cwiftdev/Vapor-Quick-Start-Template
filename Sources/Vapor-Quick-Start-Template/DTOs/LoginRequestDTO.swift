import Vapor

struct LoginRequestDTO: Content {
    let email: String
    let password: String
}

extension LoginRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}
