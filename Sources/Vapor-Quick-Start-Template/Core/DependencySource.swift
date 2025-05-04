import Vapor

protocol DependencySource: Sendable {
    var localizationService: any LocalizationService { get }
    var emailService: any EmailService { get }
    var keyService: any KeyService { get }
    var config: any EnvironmentConfiguration { get }
    var tokenService: any TokenService { get }
}

struct RequestDependencySource: DependencySource {
    private let request: Request
    init(request: Request) { self.request = request }
    
    var localizationService: any LocalizationService { AppLocalizationService(request: request) }
    var emailService: any EmailService { request.application.emailServiceType.instance(with: request) }
    var keyService: any KeyService { request.application.keyService }
    var config: any EnvironmentConfiguration { request.application.environmentConfiguration }
    var tokenService: any TokenService { AppTokenService(request: request) }
}

extension Request {
    var dSource: any DependencySource { RequestDependencySource(request: self) }
}
