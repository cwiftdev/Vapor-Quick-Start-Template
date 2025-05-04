import Vapor

// MARK: - Localizable
protocol Localizable: Sendable {
    var localizationKey: String { get }
}

// MARK: String + Localizable
extension String: Localizable {
    public var localizationKey: String { self }
}

// MARK: - LocalizationService
protocol LocalizationService: RequestInstanceService {
    /// Returns the localized string for a given localizable key, locale, and optional interpolations.
    /// - Parameters:
    ///   - localizable: The key or object representing the string to be localized.
    ///   - locale: The locale code (e.g., "en", "tr") to localize for. If `nil`, the default locale is used.
    ///   - interpolations: Optional dictionary of values to interpolate into the localized string.
    /// - Returns: A localized string with interpolations applied, if any.
    func localize(
        localizable: any Localizable,
        locale: String?,
        interpolations: [String: Any]?
    ) -> String
    /// Returns a localized version of the given content string by replacing embedded localization placeholders.
    /// - Parameters:
    ///   - content: The content string containing localization placeholders (e.g., `{{key}}`).
    ///   - locale: The locale code to localize the placeholders for. If `nil`, the default locale is used.
    ///   - partialLocalizations: A collection of partial localization providers to resolve embedded keys.
    /// - Returns: A fully localized string with all placeholders resolved for the specified locale.
    func localize(
        content: String,
        locale: String?,
        partialLocalizations: [any PartialLocalizable]
    ) -> String
}

// MARK: - PartialLocalizable
protocol PartialLocalizable: Localizable {
    /// The placeholder key in the content that should be replaced (e.g., "{{username}}").
    var replacingKey: String { get }
    /// The localization key that should be used to fetch the localized value.
    var localizationKey: String { get }
    /// Optional values to interpolate into the localized string.
    var interPolations: [String: Any]? { get }
}

extension PartialLocalizable {
    var interPolations: [String : Any]? { nil }
    var replacingKey: String { "{{\(localizationKey)}}" }
}

extension LocalizationService {
    func localize(
        localizable: any Localizable,
        locale: String? = nil,
        interpolations: [String: Any]? = nil
    ) -> String {
        return localize(localizable: localizable, locale: locale, interpolations: interpolations)
    }
}

extension Application {
    private enum LocalizationServiceStorageKey: StorageKey {
        typealias Value = any LocalizationService.Type
    }
    
    var localizationServiceType: any LocalizationService.Type {
        get {
            storage[LocalizationServiceStorageKey.self, default: AppLocalizationService.self]
        }
        set {
            storage[LocalizationServiceStorageKey.self] = newValue
        }
    }
}
