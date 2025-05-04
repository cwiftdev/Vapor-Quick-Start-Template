import Vapor
@preconcurrency import LingoVapor

struct AppLocalizationService: LocalizationService, Sendable {
    private let lingoProvider: LingoProvider
    private let acceptLanguage: String?
    private let logger = Logger(label: "com.vapor-quict-start.localizable")
    
    init(
        lingoProvider: LingoProvider,
        acceptLanguage: String? = nil
    ) {
        self.lingoProvider = lingoProvider
        self.acceptLanguage = acceptLanguage
    }
    
    init(request: Request) {
        self.init(
            lingoProvider: request.application.lingoVapor,
            acceptLanguage: request.headers.first(name: .acceptLanguage)
        )
    }
    
    func localize(
        localizable: any Localizable,
        locale: String?,
        interpolations: [String : Any]?
    ) -> String {
        let localizationKey = localizable.localizationKey
        do {
            let lingo = try lingoProvider.lingo()
            return lingo.localize(
                localizationKey,
                locale: locale ?? acceptLanguage ?? "",
                interpolations: interpolations
            )
        } catch {
            logger.error("\(localizationKey) couldn't localized: \(error.localizedDescription)")
            return localizationKey
        }
    }
    
    func localize(
        content: String,
        locale: String?,
        partialLocalizations: [any PartialLocalizable]
    ) -> String {
        var replaceContent = content
        for partialLocalization in partialLocalizations {
            let localizedPart = localize(
                localizable: partialLocalization,
                locale: locale,
                interpolations: partialLocalization.interPolations
            )
            replaceContent = replaceContent.replacingOccurrences(
                of: partialLocalization.replacingKey,
                with: localizedPart
            )
        }
        return replaceContent
    }
}
