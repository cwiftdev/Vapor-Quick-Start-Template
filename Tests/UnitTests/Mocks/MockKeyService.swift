@testable import Vapor_Quick_Start_Template

final class MockKeyService: KeyService,
                            @unchecked Sendable {
    static let defaultKey = "uniqueKey"
    static let defaultKeyHash = "c6258fb34f3772b79eee61c79d05ef15a5b938f7bfe87a88b72942dd21e1611e"

    var calledGenerateUniqueKeyCount: Int = .zero
    func generateUniqueKey() -> String {
        calledGenerateUniqueKeyCount += 1
        return MockKeyService.defaultKey
    }
}
