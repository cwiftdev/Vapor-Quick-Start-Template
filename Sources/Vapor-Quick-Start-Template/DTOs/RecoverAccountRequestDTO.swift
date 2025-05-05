import Vapor

struct RecoverAccountRequestDTO: Content {
    let password: String
    let confirmPassword: String
    let token: String
}

extension RecoverAccountRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("password", as: String.self, is: !.empty)
        validations.add("confirmPassword", as: String.self, is: !.empty)
        validations.add("token", as: String.self, is: !.empty)
    }
}
