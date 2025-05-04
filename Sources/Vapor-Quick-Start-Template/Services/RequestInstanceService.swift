import Vapor

protocol RequestInstanceService: Sendable {
    init(request: Request)
    static func instance(with request: Request) -> Self
}

extension RequestInstanceService {
    static func instance(with request: Request) -> Self { .init(request: request) }
}
