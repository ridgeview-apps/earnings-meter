//import Models
//import SwiftUI
//import PresentationViews
//import WidgetKit
//
//public struct MeterWidgetView: View {
//    
//    @Environment(\.widgetFamily) var size
//    @Environment(\.calendar) var calendar
//    @Environment(\.locale) var locale
//    
//    // MARK: - Properties
//    
//    let timeLineEntry: MeterTimeLineEntry
//    
//    private var settings: MeterSettings { timeLineEntry.meterSettings }
//    private var reading: MeterCalculator.Reading { timeLineEntry.reading }
//    
//    private var isEnabled: Bool { progressBarValue > 0 }
//    private var amountEarned: Double { reading.amountEarned }
//    private var hireStatus: MeterHireStatusView.Status { reading.hireStatus }
//    private var workStartTimeText: String { settings.formattedStartTime(in: calendar)}
//    private var workEndTimeText: String { settings.formattedEndTime(in: calendar)}
//    private var progressBarValue: Double { reading.progress }
//
//    
//    // MARK: - Initializers
//    
//    init(timeLineEntry: MeterTimeLineEntry) {
//        self.timeLineEntry = timeLineEntry
//    }
//        
//    // MARK: - Body
//
//    public var body: some View {
//        switch size {
//        case .systemSmall:
//            standardSmallWidget
//        case .systemMedium, .systemLarge, .systemExtraLarge:
//            standardMediumWidget
//        case .accessoryCircular:
//            lockScreenSmallCircularWidget
//        case .accessoryRectangular:
//            lockScreenRectangularWidget
//        case .accessoryInline:
//            lockScreenInlineTextWidget
//        @unknown default:
//            EmptyView()
//        }
//    }
//    
//    // MARK: - Layout components
//    
//    private func digitsView(style: MeterDigitsView.Style,
//                            showCurrencySymbol: Bool = true) -> some View {
//        MeterDigitsView(
//            amount: amountEarned,
//            isEnabled: isEnabled,
//            style: style,
//            showCurrencySymbol: showCurrencySymbol
//        )
//    }
//    
//    private func progressBarView(showTextLabels: Bool) -> some View {
//        MeterProgressBarView(
//            leftLabelText: workStartTimeText,
//            rightLabelText: workEndTimeText,
//            value: progressBarValue,
//            showTextLabels: showTextLabels,
//            isEnabled: isEnabled
//        )
//        .frame(maxWidth: 450)
//    }
//    
//    private func hireStatusView(font: Font, showStatusText : Bool, showEmoji: Bool) -> some View {
//        MeterHireStatusView(status: hireStatus,
//                            progressValue: progressBarValue, 
//                            showStatusText: showStatusText,
//                            showEmoji: showEmoji)
//            .font(font)
//    }
//    
//    private var circularHireStatusGauge: some View {
//        Gauge(value: progressBarValue) {
//            hireStatusView(font: .footnote, showStatusText: false, showEmoji: true)
//        } currentValueLabel: {
//            hireStatusView(font: .footnote, showStatusText: true, showEmoji: false)
//        }
//        .gaugeStyle(.accessoryCircular)
//    }
//    
//    // MARK: Standard widgets
//    
//    private var standardSmallWidget: some View {
//        Color
//            .darkGrey1
//            .overlay {
//                VStack(spacing: 12) {
//                    circularHireStatusGauge
//                        .tint(.redOne)
//                    digitsView(style: .small)
//                }
////                .padding()
//            }
//    }
//    
//    private var standardMediumWidget: some View {
//        Color.darkGrey1
//            .overlay {
//                VStack(spacing: 4) {
//                    digitsView(style: .medium)
//                    VStack(spacing: 8) {
//                        hireStatusView(font: .subheadline,
//                                       showStatusText: true,
//                                       showEmoji: true)
//                        progressBarView(showTextLabels: true)
//                    }
//                }
////                .padding(.vertical, 12)
//                .padding()
//            }
//    }
//    
//    // MARK: Lock screen widgets
//    
//    private var lockScreenSmallCircularWidget: some View {
//        Gauge(value: progressBarValue) {
//            hireStatusView(font: .footnote, showStatusText: false, showEmoji: true)
//        } currentValueLabel: {
//            digitsView(style: .tiny, showCurrencySymbol: false)
//        }
//        .gaugeStyle(.accessoryCircular)
//    }
//    
//    private var lockScreenRectangularWidget: some View {
//        HStack {
//            circularHireStatusGauge
//            digitsView(style: .small, showCurrencySymbol: true)
//        }
//    }
//    
//    private var lockScreenInlineTextWidget: some View {
//        let localizedTitle = NSLocalizedString("meter.widget.inline.earnings.today", comment: "")
//        let fullAmountText = amountEarned.currencyFormatted(forLocale: locale)
//        return Text("\(localizedTitle): \(fullAmountText)")
//    }
//}
//
//
//// MARK: - Previews
//
////#if DEBUG
////private struct WrapperProvider: TimelineProvider {
////    
////    typealias Entry = MeterTimeLineEntry
////    
////    func placeholder(in context: Context) -> MeterTimeLineEntry { .placeholder }
////    func getSnapshot(in context: Context, completion: @escaping (MeterTimeLineEntry) -> Void) {
////        completion(.placeholder)
////    }
////    func getTimeline(in context: Context, completion: @escaping (Timeline<MeterTimeLineEntry>) -> Void) {
////        completion(.init(entries: [], policy: .atEnd))
////    }
////}
////private struct WrapperWidget: Widget {
////    
////    var body: some WidgetConfiguration {
////        StaticConfiguration(kind: "EarningsMeterWidgetPreview",
////                            provider: WrapperProvider()) { entry in
////            MeterWidgetView(timeLineEntry: entry)
////        }
////        .supportedFamilies([.systemSmall,
////                            .systemMedium,
////                            .accessoryCircular,
////                            .accessoryRectangular])
////        .configurationDisplayName(Text("meter.widget.configuration.display.name"))
////        .description(Text("meter.widget.configuration.description"))
////    }
////}
//
////
//// Note: it's impossible to preview iOS16 and iOS17 via the #Preview macro (it only works when previewing
//// iOS 17). Workaround is to write completely separate PreviewProvider logic for iOS 16
//// and comment preview logic in / out as applicable 🙄)
////
//// See // see: https://developer.apple.com/forums/thread/731182
//
////@available(iOS 17.0, *)
////#Preview(as: .systemMedium) {
////    WrapperWidget()
////} timeline: {
////    MeterTimeLineEntry(date: .now,
////                       reading: .init(amountEarned: 0, progress: 0, status: .beforeWork),
////                       meterSettings: ModelStubs.dayTime_0900_to_1700())
////    MeterTimeLineEntry(date: .now + 5,
////                       reading: .init(amountEarned: 100, progress: 0.25, status: .atWork),
////                       meterSettings: ModelStubs.dayTime_0900_to_1700())
////    MeterTimeLineEntry(date: .now + 10,
////                       reading: .init(amountEarned: 200, progress: 0.5, status: .atWork),
////                       meterSettings: ModelStubs.dayTime_0900_to_1700())
////    MeterTimeLineEntry(date: .now + 15,
////                       reading: .init(amountEarned: 300, progress: 0.75, status: .atWork),
////                       meterSettings: ModelStubs.dayTime_0900_to_1700())
////    MeterTimeLineEntry(date: .now + 15,
////                       reading: .init(amountEarned: 400, progress: 1.0, status: .afterWork),
////                       meterSettings: ModelStubs.dayTime_0900_to_1700())
////}
//
// // iOS 16 preview
////
////struct WidgetPreviewIOS16: PreviewProvider {
////    static var previews: some View {
////
////        Group {
////            MeterWidgetView(timeLineEntry: .init(date: Date(), reading: .init(amountEarned: 1234, progress: 1, status: .atWork), meterSettings: .placeholder))
////                .previewContext(WidgetPreviewContext(family: .systemSmall))
////        }
////    }
////}
//
////extension View {
////    @ViewBuilder func widgetContainerBackground(color: Color = .darkGrey1) -> some View {
////        if #available(iOSApplicationExtension 17.0, *) {
////            containerBackground(for: .widget) {
////                color
////            }
////        } else {
////            self
////        }
////    }
////}
////
////
//////#Preview("At work") {
//////    nineToFivePreview(status: .atWork, progressBarValue: 0.5)
//////}
