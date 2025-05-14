@testable import Vapor_Quick_Start_Template

struct MockEnvironmentConfiguration: EnvironmentConfiguration {
    var redisUrl: String = "redisUrl"
    let jwksString: String = "jwksString"
    let databaseUrl: String = "databaseUrl"
    let clientUrl: String = "localhost:8080"
    let apiUrl: String = "localhost:8080"
    let smtpHost: String = "smtpHost"
    let smtpMail: String = "smtpMail"
    let smtpPassword: String = "smtpPassword"
}
