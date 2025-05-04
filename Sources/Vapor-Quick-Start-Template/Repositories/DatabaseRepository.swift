import Fluent
import Vapor

protocol DatabaseRepository: Sendable {
    init(database: any Database)
}
