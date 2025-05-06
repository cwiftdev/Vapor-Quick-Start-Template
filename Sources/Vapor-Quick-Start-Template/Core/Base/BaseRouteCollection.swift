import Vapor

protocol BaseRouteCollection: RouteCollection {
    associatedtype UseCaseType: UseCase
    func useCase(on request: Request) -> UseCaseType
}

extension BaseRouteCollection {
    func useCase(on request: Request) -> UseCaseType { .instance(on: request.dSource) }
}
