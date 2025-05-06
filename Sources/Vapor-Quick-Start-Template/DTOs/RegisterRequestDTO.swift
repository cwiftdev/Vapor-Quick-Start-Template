import Vapor

struct RegisterRequestDTO: Content {
    let email: String
    let password: String
    let confirmPassword: String
}

extension RegisterRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...15))
        validations.add("confirmPassword", as: String.self, is: .count(8...15))
    }
}

extension UserEntity {
    convenience init(
        from register: RegisterRequestDTO,
        hash: String,
        role: UserRole = .user
    ) {
        self.init(
            email: register.email,
            passwordHash: hash,
            role: role
        )
    }
}
