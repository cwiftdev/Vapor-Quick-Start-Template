import Vapor

struct AppEnvironmentConfiguration: EnvironmentConfiguration {
    let jwksString: String
    let databaseUrl: String
    var redisUrl: String
    let clientUrl: String
    let apiUrl: String
    let smtpHost: String
    let smtpMail: String
    let smtpPassword: String
    
    init() {
        jwksString = Environment.get(key: "JWKS")
        databaseUrl = Environment.get(key: "DATABASE_URL")
        redisUrl = Environment.get(key: "REDIS_URL")
        clientUrl = Environment.get(key: "CLIENT_URL")
        apiUrl = Environment.get(key: "API_URL")
        smtpHost = Environment.get(key: "SMTP_HOST")
        smtpMail = Environment.get(key: "SMTP_MAIL")
        smtpPassword = Environment.get(key: "SMTP_PASSWORD")
    }
}
