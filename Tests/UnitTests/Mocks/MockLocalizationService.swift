@testable import Vapor_Quick_Start_Template
import Vapor

final class MockLocalizationService: LocalizationService,
                                     @unchecked Sendable {
    init(request: Request) {}
    init() {}
    typealias LocalizeMethodParameter = (localizable: any Localizable, locale: String?, interpolations: [String : Any]?)
    var calledLocalizeMethodParameter: LocalizeMethodParameter?
    var calledLocalizeMethodCount = 0
    var stubbedLocalizeMethodReturnParameter: String?
    func localize(
        localizable: any Localizable,
        locale: String?,
        interpolations: [String : Any]?
    ) -> String {
        calledLocalizeMethodParameter = (localizable, locale, interpolations)
        calledLocalizeMethodCount += 1
        return stubbedLocalizeMethodReturnParameter ?? localizable.localizationKey
    }
    
    typealias LocalizeWithPartialMethodParameter = (content: String, locale: String?, partialLocalizations: [any PartialLocalizable])
    var calledLocalizeWithPartialMethodParameter: LocalizeWithPartialMethodParameter?
    var calledLocalizeWithPartialMethodCount = 0
    var stubbedLocalizeWithPartialMethodReturnParameter: String?
    func localize(content: String, locale: String?, partialLocalizations: [any PartialLocalizable]) -> String {
        calledLocalizeWithPartialMethodParameter = (content, locale, partialLocalizations)
        calledLocalizeMethodCount += 1
        return stubbedLocalizeWithPartialMethodReturnParameter ?? content.hash
    }
}
