import Vapor

extension String {
    var hash: String { SHA256.hash(data: data(using: .utf8)!).hex }
}
