import Vapor

protocol UseCase: Sendable {
    init(dSource: any DependencySource)
}

extension UseCase {
    static func instance(on dSource: any DependencySource) -> Self { .init(dSource: dSource) }
}
