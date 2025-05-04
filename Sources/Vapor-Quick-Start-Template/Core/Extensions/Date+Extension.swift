import Foundation

extension Date {
    static var now: Date { Date() }
    static func addTimeIntervalNow(_ timeToAdd: TimeInterval) -> Date { .now.addingTimeInterval(timeToAdd) }
}
