import Vapor

struct ResetPasswordRequestDTO: Content {
    let email: String
}

extension ResetPasswordRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
