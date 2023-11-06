import Foundation
import Models
import SwiftUI

public struct MeterDigitsView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public enum Style {
        case tiny
        case small
        case medium
        case large
    }
    
    let amount: Double
    let isEnabled: Bool
    var style: Style
    var showCurrencySymbol: Bool = true
    
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


// MARK: - Convenience init

public extension MeterDigitsView {
    
    init(reading: MeterCalculator.Reading,
         style: Style,
         showCurrencySymbol: Bool = true) {
        self = .init(amount: reading.amountEarned,
                     isEnabled: reading.progress > 0,
                     style: style,
                     showCurrencySymbol: showCurrencySymbol)
    }
}

// MARK: - Previews

#if DEBUG

#Preview {
    ScrollView {
        VStack {
            MeterDigitsView(amount: 123.45, isEnabled: true, style: .medium)
            MeterDigitsView(amount: 123.45, isEnabled: false, style: .medium)
            MeterDigitsView(amount: 123.45, isEnabled: true, style: .small)
            MeterDigitsView(amount: 123.45, isEnabled: true, style: .tiny)
            MeterDigitsView(amount: 12333334112341111.45, isEnabled: true, style: .medium)
            MeterDigitsView(amount: 123.45, isEnabled: true, style: .medium, showCurrencySymbol: false)
        }
        .background(Color.darkGrey1)
    }
    .styledPreview()
}
#endif
