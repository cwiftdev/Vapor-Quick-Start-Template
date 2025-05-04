import Vapor

protocol DependencySource: Sendable {
    var localizationService: any LocalizationService { get }
    var emailService: any EmailService { get }
    var keyService: any KeyService { get }
    var config: any EnvironmentConfiguration { get }
    var tokenService: any TokenService { get }
}

final class RequestDependencySource: @unchecked Sendable {
    private let request: Request
    init(request: Request) { self.request = request }
    
    private var app: Application { request.application }
    
    private lazy var _localizationService: any LocalizationService = {
        app.localizationServiceType.instance(with: request)
    }()
    private lazy var _emailService: any EmailService = {
        app.emailServiceType.instance(with: request)
    }()
    private lazy var _tokenService: any TokenService = {
        app.tokenServiceType.instance(with: request)
    }()
}

extension RequestDependencySource: DependencySource {
    var localizationService: any LocalizationService { _localizationService }
    var emailService: any EmailService { _emailService }
    var keyService: any KeyService { app.keyService }
    var config: any EnvironmentConfiguration { app.environmentConfiguration }
    var tokenService: any TokenService { _tokenService }
}

extension Request {
    var dSource: any DependencySource { RequestDependencySource(request: self) }
}
