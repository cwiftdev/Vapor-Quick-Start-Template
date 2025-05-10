import Vapor

struct SendResetPasswordMailRequestDTO: Content {
    let email: String
}

extension SendResetPasswordMailRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
