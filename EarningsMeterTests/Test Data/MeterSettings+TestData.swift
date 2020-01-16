import Foundation
@testable import Earnings_Meter

extension DateFormatter {
    
    static let testShortTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
