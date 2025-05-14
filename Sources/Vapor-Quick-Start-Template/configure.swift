import NIOSSL
import Vapor
import QueuesRedisDriver
import LingoVapor

public func configure(_ app: Application) async throws {
    let environmentConfig = app.environmentConfiguration
    
    try app.jwt.signers.use(jwksJSON: environmentConfig.jwksString)
    
    app.lingoVapor.configuration = LingoConfiguration(
        defaultLocale: Constants.Language.defaultLanguageKey,
        localizationsDir: Constants.Directory.localizations.pathString
    )
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith,
            .userAgent,
            .accessControlAllowOrigin,
            .accessControlAllowHeaders,
            .accessControlAllowMethods,
            .accessControlRequestMethod,
            
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
    app.middleware.use(ErrorMiddleware())

    try app.configureDatabase()
    if app.environment != .testing {
        try app.queues.use(
            .redis(url: environmentConfig.redisUrl)
        )
        app.queues.add(SendEmailJob())
    }
    
    app.migrations.add(CreateUserEntity())
    app.migrations.add(CreateUserEmailVerificationTokenEntity())
    app.migrations.add(CreateUserRefreshTokenEntity())
    app.migrations.add(CreateUserResetPasswordTokenEntity())
    
    try await app.autoMigrate()
    try app.queues.startInProcessJobs()
    try routes(app)
}
