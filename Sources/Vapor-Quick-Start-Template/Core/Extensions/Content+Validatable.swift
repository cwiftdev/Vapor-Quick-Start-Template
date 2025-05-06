import Vapor

extension Content {
    func parseJsonString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw Abort(.internalServerError, reason: "Failed to encode JSON string.")
        }
        return jsonString
    }
}

extension Validatable {
    static func validate(content: any Content) throws {
        let json = try content.parseJsonString()
        try validate(json: json)
    }
}

extension Validatable where Self: Content {
    func validate() throws { try Self.validate(content: self) }
}
