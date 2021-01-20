import Foundation

final class MeterDigitsViewModel {
    
    // MARK: - State
    let amountText: String
    let amountBackgroundText: String
    let currencySymbol: String
    
    init(amount: Double,
         formatter: NumberFormatter = .decimalStyle) {
        amountText = formatter.string(from: amount as NSNumber) ?? ""
        amountBackgroundText = amountText
                                .map { $0.isNumber ? "8" : String($0) }
                                .joined()
        currencySymbol = formatter.currencySymbol
    }
}
