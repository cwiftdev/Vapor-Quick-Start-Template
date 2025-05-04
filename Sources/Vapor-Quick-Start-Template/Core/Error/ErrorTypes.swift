import Vapor

typealias ApplicationError = AbortError & DebuggableError & Content

protocol BaseErrorProtocol: ApplicationError {
    var identifier: String { get }
    var systemMessage: String? { get }
}

protocol LocalizableErrorProtocol: BaseErrorProtocol, Localizable { }

extension LocalizableErrorProtocol {
    var identifier: String { localizationKey }
}
