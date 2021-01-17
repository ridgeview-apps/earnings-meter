import Foundation

// MARK: - DateFormatters
extension DateFormatter {
    
    static let shortTimeStyle: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter
    }()
}

// MARK: - Number Formatters
extension NumberFormatter {
    
    static let decimalStyle: NumberFormatter = {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        return numFormatter
    }()
    
    static let currencyStyle: NumberFormatter = {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        return numFormatter
    }()
}


struct Formatters {
    
    var dateStyles: DateFormatters
    struct DateFormatters {
        var shortTime: DateFormatter = .shortTimeStyle
    }
    
    var numberStyles: NumberFormatters
    struct NumberFormatters {
        var decimal: NumberFormatter = .decimalStyle
        var currency: NumberFormatter = .currencyStyle
    }
}

// MARK: - Real instance
extension Formatters {
    
    static let real = Formatters(
        dateStyles: .init(shortTime: .shortTimeStyle),
        numberStyles: .init(decimal: .decimalStyle)
    )
}

// MARK: - Fake instance
#if DEBUG
extension Formatters {
    static var  fake = real
}
#endif
