import Foundation

public extension Double {
    func rounded(toDecimalPlaces fractionDigits: Int) -> Double {
        guard fractionDigits != 0 else { return self }
        let multiplier = pow(10, Double(fractionDigits))
        return ((self * multiplier).rounded() / multiplier)
    }
    
    func currencyFormatted(forLocale locale: Locale) -> String {
        self.formatted(.currency(code: locale.currency?.identifier ?? ""))
    }
}
