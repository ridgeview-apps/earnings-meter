import Foundation
import SwiftUI

public struct MeterDigitsView: View {

    public enum Style {
        case tiny
        case small
        case medium
        case large
    }
    
    public let amount: Double
    public let isEnabled: Bool
    public let style: Style
    public let showCurrencySymbol: Bool
    
    public init(amount: Double,
                isEnabled: Bool,
                style: Style = .medium,
                showCurrencySymbol: Bool = true) {
        self.amount = amount
        self.isEnabled = isEnabled
        self.style = style
        self.showCurrencySymbol = showCurrencySymbol
    }

    public var body: some View {
        HStack(alignment: .center) {
            if showCurrencySymbol {
                currencySymbolText
            }
            amountText
        }
        .shrinkableSingleLine()
    }
    
    
    // MARK: - Layout views
    
    private var currencySymbolText: some View {
        Text(amountFormatter.currencySymbol)
            .foregroundColor(.white)
            .font(symbolFont)
    }
    
    private var amountText: some View {
        ZStack(alignment: .trailing) {
            faintBackgroundAmount
            Text(amount as NSNumber, formatter: amountFormatter)
        }
        .font(digitFont)
        .foregroundColor(isEnabled ? .redOne : Color.redTwo)
    }
    
    @ViewBuilder private var faintBackgroundAmount: some View {
        let amountText = amountFormatter.string(from: amount as NSNumber) ?? "0.00"
        let digitsOfEight = amountText
                                .map { $0.isNumber ? "8" : String($0) }
                                .joined()
        Text(digitsOfEight).opacity(0.1)
    }
    
    private var symbolFont: Font {
        switch style {
        case .tiny:
            return .digitFont(size: 12)
        case .small:
            return .digitFont(size: 20)
        case .medium:
            return .digitFont(size: 35)
        case .large:
            return .digitFont(size: 50)
        }
    }
    
    private var digitFont: Font {
        switch style {
        case .tiny:
            return .digitFont(size: 24)
        case .small:
            return .digitFont(size: 40)
        case .medium:
            return .digitFont(size: 70)
        case .large:
            return .digitFont(size: 100)
        }
    }
}


private let amountFormatter: NumberFormatter = {
    let numFormatter = NumberFormatter()
    numFormatter.numberStyle = .decimal
    numFormatter.minimumFractionDigits = 2
    numFormatter.maximumFractionDigits = 2
    return numFormatter
}()

// MARK: - Previews

#if DEBUG

struct MeterDigitsView_Previews: PreviewProvider {
    
    static var previews: some View {
        Font.registerCustomFonts()
        
        return ScrollView {
            VStack {
                MeterDigitsView(amount: 123.45, isEnabled: true)
                MeterDigitsView(amount: 123.45, isEnabled: false)
                MeterDigitsView(amount: 123.45, isEnabled: true, style: .small)
                MeterDigitsView(amount: 123.45, isEnabled: true, style: .tiny)
                MeterDigitsView(amount: 12333334112341111.45, isEnabled: true)
            }.background(Color.darkGrey1)
        }
        
    }
}
#endif
