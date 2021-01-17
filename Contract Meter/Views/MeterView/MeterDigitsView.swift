import Foundation
import SwiftUI

struct MeterDigitsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var viewModel: MeterDigitsViewModel
    private var isEnabled: Bool
    
    init(amount: Double,
         isEnabled: Bool,
         formatter: NumberFormatter = .decimalStyle) {
        viewModel = MeterDigitsViewModel(amount: amount,
                                         formatter: formatter)
        self.isEnabled = isEnabled
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(viewModel.currencySymbol)
                .foregroundColor(.white)
                .lineLimit(1)
                .font(.largeTitle)
                .layoutPriority(0)
                
            ZStack(alignment: .trailing) {
                Text(viewModel.amountText)
                Text(viewModel.amountBackgroundText).opacity(0.1)
            }
            .font(digitFont)
            .foregroundColor(digitColor)
            .layoutPriority(1)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    private var digitColor: Color {
        isEnabled ? .redOne : Color.redTwo
    }
    
    private var digitFont: Font {
        return horizontalSizeClass == .compact ? .digitFont(size: 70) : .digitFont(size: 130)
    }
}

#if DEBUG
struct MeterDigitsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeterDigitsView(amount: 123.45, isEnabled: true)
            MeterDigitsView(amount: 123.45, isEnabled: false)            
        }
        .background(Color.black)
    }
}
#endif
