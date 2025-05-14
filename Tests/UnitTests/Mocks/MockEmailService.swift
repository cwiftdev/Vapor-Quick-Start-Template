@testable import Vapor_Quick_Start_Template
import Vapor
import Queues

final class MockEmailService: EmailService,
                              @unchecked Sendable {
    init(request: Request) { }
    init() {}
    
    var calledSendMethodParameter: (any EmailTemplate)?
    var calledSendMethodCount = 0
    func send(_ template: any EmailTemplate) async throws {
        calledSendMethodParameter = template
        calledSendMethodCount += 1
    }
    
    nonisolated(unsafe) static var stubbedEmailService: MockEmailService!
    static func instance(with request: Request) -> Self { stubbedEmailService as! Self }
}
