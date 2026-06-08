import Foundation
import Models
import SwiftUI

public struct MeterDigitsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.appAnimationsEnabled) private var appAnimationsEnabled

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

    @Environment(\.locale) private var locale

    private var amountFormatStyle: FloatingPointFormatStyle<Double> {
        .number
            .precision(.fractionLength(2))
            .locale(locale)
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
        Text(locale.currencySymbol ?? "$")
            .foregroundStyle(Color.white.opacity(isEnabled ? 0.7 : 0.45))
            .font(.system(size: symbolFontSize, weight: .semibold, design: .rounded))
    }

    private var amountText: some View {
        ZStack(alignment: .trailing) {
            faintBackgroundAmount
            Text(amount, format: amountFormatStyle)
                .contentTransition(
                    appAnimationsEnabled ? .numericText(value: amount) : .identity
                )
        }
        .font(digitFont)
        .foregroundColor(amountForegroundColor)
    }

    @ViewBuilder private var faintBackgroundAmount: some View {
        let formatted = amount.formatted(amountFormatStyle)
        let digitsOfEight =
            formatted
            .map { $0.isNumber ? "8" : String($0) }
            .joined()
        Text(digitsOfEight)
            .opacity(backgroundDigitOpacity)
    }

    private var amountForegroundColor: Color {
        isEnabled ? .redOne : Color.redTwo.opacity(0.78)
    }

    private var backgroundDigitOpacity: Double {
        isEnabled ? 0.1 : 0.22
    }

    private var symbolFontSize: CGFloat {
        switch style {
        case .tiny:
            return 10
        case .small:
            return 16
        case .medium:
            return 28
        case .large:
            return 40
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

// MARK: - Convenience init

public extension MeterDigitsView {

    init(
        reading: MeterReading,
        style: Style,
        showCurrencySymbol: Bool = true
    ) {
        self = .init(
            amount: reading.amountEarned,
            isEnabled: reading.progress > 0,
            style: style,
            showCurrencySymbol: showCurrencySymbol
        )
    }
}

// MARK: - Previews

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
