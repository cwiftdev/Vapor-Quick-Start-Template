@testable @preconcurrency import Vapor_Quick_Start_Template
import XCTest

struct TestDependencySource {
    var _repositories: (any RepositoryService)?
    var _config: (any EnvironmentConfiguration)?
    var _localizationService: (any LocalizationService)?
    var _emailService: (any EmailService)?
    var _keyService: (any KeyService)?
    var _tokenService: (any TokenService)?
}

extension TestDependencySource: DependencySource {
    var config: any EnvironmentConfiguration { unwrap(_config) }
    var localizationService: any LocalizationService { unwrap(_localizationService) }
    var emailService: any EmailService { unwrap(_emailService) }
    var keyService: any KeyService { unwrap(_keyService) }
    var repositories: any RepositoryService { unwrap(_repositories) }
    var tokenService: any TokenService { unwrap(_tokenService) }
}
