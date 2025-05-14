import XCTest

func unwrap<T>(_ optional: T?) -> T {
    do {
        return try XCTUnwrap(optional)
    } catch {
        fatalError("Please add mock for \(String(describing: type(of: optional)))")
    }
}
