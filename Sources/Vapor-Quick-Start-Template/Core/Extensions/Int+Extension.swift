import Foundation

extension Int {
    var toDouble: Double { Double(self) }
}

extension Int {
    static func minute(_ minute: Int) -> Int { (60 * minute) }
}
