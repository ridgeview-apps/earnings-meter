import Foundation

public extension Formatter {
    
    static let currencyStyle: NumberFormatter = {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        return numFormatter
    }()
    
    static let decimalStyle: NumberFormatter = {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        return numFormatter
    }()

}
