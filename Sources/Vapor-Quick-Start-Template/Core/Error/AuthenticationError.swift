import Vapor

enum AuthenticationError {
    case passwordsDontMatch
    case emailAlreadyExist
    case emailIsNotVerified
    case emailAlreadyVerified
    case invalidPassword
    case userNotFound
    case tokenExpired
    case securityTokenNotFound
}

extension AuthenticationError: LocalizableErrorProtocol {
    var localizationKey: String {
        let errorPrefix = "error.auth"
        switch self {
        case .passwordsDontMatch:
            return "\(errorPrefix).passwords_dont_match"
        case .emailAlreadyExist:
            return "\(errorPrefix).email_already_exist"
        case .emailIsNotVerified:
            return "\(errorPrefix).email_is_not_verified"
        case .emailAlreadyVerified:
            return "\(errorPrefix).email_is_already_verified"
        case .invalidPassword:
            return "\(errorPrefix).invalid_password"
        case .userNotFound:
            return "\(errorPrefix).user_not_found"
        case .tokenExpired:
            return "\(errorPrefix).token_expired"
        case .securityTokenNotFound:
            return "\(errorPrefix).security_token_not_found"
        }
    }
    
    var systemMessage: String? {
        switch self {
        case .passwordsDontMatch:
            return "Passwords dont match"
        case .emailAlreadyExist:
            return "Email already exist"
        case .emailIsNotVerified:
            return "Email is not verified"
        case .emailAlreadyVerified:
            return "Email already verified"
        case .invalidPassword:
            return "Ivalid password"
        case .userNotFound:
            return "User not found"
        case .tokenExpired:
            return "Token expired"
        case .securityTokenNotFound:
            return "Token not found"
        }
    }
    
    var status: HTTPResponseStatus {
        switch self {
        case .passwordsDontMatch, .invalidPassword:
            return .badRequest
        case .emailAlreadyExist, .emailAlreadyVerified:
            return .conflict
        case .emailIsNotVerified, .tokenExpired, .securityTokenNotFound:
            return .unauthorized
        case .userNotFound:
            return .notFound
        }
    }
}
