import Vapor

extension Environment {
    static func get(key: String) -> String {
        guard let value = get(key) else {
            fatalError("There is no environment value for key: \(key)")
        }
        return value
    }
}
