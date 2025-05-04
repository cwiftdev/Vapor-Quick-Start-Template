import Vapor

enum Constants {
    enum Directory: String {
        case resources = "Resources/"
        case emails = "EmailTemplates/"
        case localizations = "Localizations/"
        
        var fullPathString: String {
            let workingPath = DirectoryConfiguration.detect().workingDirectory
            return workingPath.appending(pathString)
        }
        
        var pathString: String {
            let resourcesPath = Directory.resources.rawValue
            switch self {
            case .resources:
                return resourcesPath
            default:
                return resourcesPath.appending(rawValue)
            }
        }
    }
    enum Language {
        static let defaultLanguageKey = "en"
    }
    enum TokenDuration {
        static let ACCESS_TOKEN = Double.minute(30)
        static let REFRESH_TOKEN = Double.day(7)
        static let EMAIL_TOKEN = Double.day(1)
        static let RESET_PASSWORD_TOKEN = Double.hour(1)
    }
}
