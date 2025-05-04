import FluentKit
import PostgresNIO

extension Error {
    var isDBConstraintFailureError: Bool {
        guard let dbError = self as? (any DatabaseError) else { return false }
        return dbError.isConstraintFailure
    }
    
    var failedConstraintDescription: String? {
        guard
            isDBConstraintFailureError,
            let psqlError = (self as? PSQLError)
        else { return nil }
        return psqlError.serverInfo?[.detail]
    }
}
