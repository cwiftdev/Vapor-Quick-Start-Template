import Vapor

protocol BaseUseCase: Sendable {
    init(dSource: any DependencySource)
}

extension BaseUseCase {
    static func instance(on dSource: any DependencySource) -> Self { .init(dSource: dSource) }
}
