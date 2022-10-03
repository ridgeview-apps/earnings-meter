import SwiftUI
import Combine
import ViewComponents
import WidgetKit

public struct MeterWidgetView: View {
    
    @Environment(\.widgetFamily) var size
    
    // MARK: - Properties
    
    public let isEnabled: Bool
    public let amountEarned: Double
    public let hireStatus: MeterHireStatusView.Status
    public let workStartTimeText: String
    public let workEndTimeText: String
    public let progressBarValue: Double
    
    
    // MARK: - Initializers
    
    public init(isEnabled: Bool,
                amountEarned: Double,
                hireStatus: MeterHireStatusView.Status,
                workStartTimeText: String,
                workEndTimeText: String,
                progressBarValue: Double) {
        self.isEnabled = isEnabled
        self.amountEarned = amountEarned
        self.hireStatus = hireStatus
        self.workStartTimeText = workStartTimeText
        self.workEndTimeText = workEndTimeText
        self.progressBarValue = progressBarValue
    }
    
    
    // MARK: - Body

    public var body: some View {
        switch size {
        case .systemSmall:
            standardSmallWidget
        case .systemMedium, .systemLarge, .systemExtraLarge:
            standardMediumWidget
        case .accessoryCircular:
            lockScreenSmallCircularWidget
        case .accessoryRectangular:
            lockScreenRectangularWidget
        case .accessoryInline:
            lockScreenInlineTextWidget
        @unknown default:
            EmptyView()
        }
    }
    
    // MARK: - Layout components
    
    private func titleView(font: Font) -> some View {
        Text("meter.widget.earnings.today.title")
            .font(font)
            .shrinkableSingleLine()
            .padding([.leading, .trailing], 20)
            .foregroundColor(.white)
    }
    
    private func digitsView(style: MeterDigitsView.Style,
                            showCurrencySymbol: Bool = true) -> some View {
        MeterDigitsView(
            amount: amountEarned,
            isEnabled: isEnabled,
            style: style,
            showCurrencySymbol: showCurrencySymbol
        )
    }
    
    private func progressBarView(showTextLabels: Bool) -> some View {
        MeterProgressBarView(
            leftLabelText: workStartTimeText,
            rightLabelText: workEndTimeText,
            value: progressBarValue,
            showTextLabels: showTextLabels,
            isEnabled: isEnabled
        )
        .frame(maxWidth: 450)
    }
    
    private func hireStatusView(font: Font, showStatusText : Bool, showEmoji: Bool) -> some View {
        MeterHireStatusView(status: hireStatus, showStatusText: showStatusText, showEmoji: showEmoji)
            .font(font)
    }
    
    private var circularHireStatusGauge: some View {
        Gauge(value: progressBarValue) {
            hireStatusView(font: .footnote, showStatusText: false, showEmoji: true)
        } currentValueLabel: {
            hireStatusView(font: .footnote, showStatusText: true, showEmoji: false)
        }
        .gaugeStyle(.accessoryCircular)
    }
    
    // MARK: Standard widgets
    
    private var standardSmallWidget: some View {
        ZStack {
            Color.darkGrey1
            VStack(spacing: 12) {
                circularHireStatusGauge
                    .tint(isEnabled ? .redOne : .redTwo)
                digitsView(style: .small)
            }
            .padding([.leading, .trailing], 12)
        }
    }
    
    private var standardMediumWidget: some View {
        ZStack {
            Color.darkGrey1
            HStack(spacing: 20) {
                circularHireStatusGauge
                    .tint(isEnabled ? .redOne : .redTwo)
                digitsView(style: .medium)
            }
            .padding([.leading, .trailing], 20)
        }
    }
    
    // MARK: Lock screen widgets
    
    private var lockScreenSmallCircularWidget: some View {
        Gauge(value: progressBarValue) {
            hireStatusView(font: .footnote, showStatusText: false, showEmoji: true)
        } currentValueLabel: {
            digitsView(style: .tiny, showCurrencySymbol: false)
        }
        .gaugeStyle(.accessoryCircular)
    }
    
    private var lockScreenRectangularWidget: some View {
        HStack {
            circularHireStatusGauge
            digitsView(style: .small, showCurrencySymbol: true)
        }
    }
    
    private var lockScreenInlineTextWidget: some View {
        let localizedTitle = NSLocalizedString("meter.widget.inline.earnings.today", comment: "")
        let fullAmountText = currencyFormatter.string(from: amountEarned as NSNumber) ?? "0.00"
        return Text("\(localizedTitle): \(fullAmountText)")
    }
    
}

private let currencyFormatter: NumberFormatter = {
    let numFormatter = NumberFormatter()
    numFormatter.numberStyle = .currency
    numFormatter.minimumFractionDigits = 2
    numFormatter.maximumFractionDigits = 2
    return numFormatter
}()


// MARK: - Previews

//#if DEBUG
struct MeterWidgetView_Previews: PreviewProvider {
    
    static func nineToFivePreview(isEnabled: Bool = true,
                                  amount: Double = 123.45,
                                  hireStatus: MeterHireStatusView.Status = .free,
                                  progressBarValue: Double = 0.25)-> some View {
        MeterWidgetView(
            isEnabled: isEnabled,
            amountEarned: amount,
            hireStatus: hireStatus,
            workStartTimeText: "09:00",
            workEndTimeText: "17:00",
            progressBarValue: progressBarValue
        )
    }
    
    static var previews: some View {
        Font.registerCustomFonts()
        
        return Group {
            nineToFivePreview(isEnabled: false, hireStatus: .free)
            nineToFivePreview(isEnabled: true, hireStatus: .atWork(progressValue: 0.5))
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
//        .previewOption(locale: .es) /*/ Spanish language */
    }
}

//#endif
