import Vapor

struct SendEmailVerificationRequestDTO: Content {
    let email: String
}

extension SendEmailVerificationRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
