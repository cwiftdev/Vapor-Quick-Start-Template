import Foundation

extension Double {
    static func minute(_ minute: Int) -> Double { (60 * minute).toDouble }
    static func hour(_ hour: Int) -> Double { hour.toDouble * minute(60) }
    static func day(_ day: Int) -> Double { day.toDouble * hour(24) }
}
