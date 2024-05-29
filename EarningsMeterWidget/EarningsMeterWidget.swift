import DataStores
import Intents
import Models
import SwiftUI
import PresentationViews
import WidgetKit

private final class WidgetBundlePin {}

@main
struct EarningsMeterWidget: Widget {
    let kind: String = "EarningsMeterWidget"
    
    private let environment: WidgetEnvironment
    private let timelineProvider: MeterTimeLineProvider
    
    init() {
        self.environment = WidgetEnvironment.shared(loadedFrom: Bundle(for: WidgetBundlePin.self))
        environment.userDefaults?.migrateLegacyValuesIfNeeded()
        self.timelineProvider = MeterTimeLineProvider(userDefaults: environment.userDefaults)
    }
    
    
    // MARK: - Layout
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: timelineProvider) { entry in
            MainWidgetView(entry: entry)
                .overlay(alignment: .topTrailing) { widgetOverlayTitle }
        }
        .supportedFamilies([.systemSmall,
                            .systemMedium,
                            .accessoryCircular,
                            .accessoryRectangular])
        .configurationDisplayName(Text(.widgetMeterConfigurationDisplayName))
        .description(Text(.widgetMeterConfigurationDescription))
    }
    
    @ViewBuilder private var widgetOverlayTitle: some View {
        if let widgetOverlayTitle = environment.widgetOverlayTitle, !widgetOverlayTitle.isEmpty {
            Text(widgetOverlayTitle)
                .font(.caption2)
                .foregroundStyle(.white)
        }
    }
}


// MARK: - MeterWidgetView

struct MainWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.calendar) var calendar
    
    let entry: MeterTimeLineEntry
    
    var body: some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                smallWidget
            case .systemMedium, .systemLarge, .systemExtraLarge:
                mediumWidget
            case .accessoryCircular:
                lockScreenSmallCircularWidget
            case .accessoryRectangular:
                lockScreenRectangularWidget
            case .accessoryInline:
                EmptyView() // Unsupported widget sizes
            @unknown default:
                EmptyView()
            }
        }
        .withWidgetContainerBackgroundColor()
    }
    
    private var smallWidget: some View {
        borderedWidget {
            VStack(spacing: 12) {
                CircularHireStatusGauge(reading: entry.reading)
                    .tint(.redOne)
                MeterDigitsView(reading: entry.reading,
                                style: .small,
                                showCurrencySymbol: true)
            }
        }
    }
    
    private var mediumWidget: some View {
        borderedWidget {
            VStack(spacing: 4) {
                MeterDigitsView(reading: entry.reading,
                                style: .medium,
                                showCurrencySymbol: true)
                VStack(spacing: 8) {
                    MeterHireStatusView(reading: entry.reading,
                                        showStatusText: true,
                                        showEmoji: true)
                    .font(.subheadline)
                    MeterProgressBarView(settings: entry.meterSettings,
                                         reading: entry.reading,
                                         showsTextLabels: true,
                                         calendar: calendar)
                    .frame(maxWidth: 450)
                }
            }
        }
    }
    
    private var lockScreenSmallCircularWidget: some View {
        Gauge(value: entry.reading.progress) {
            MeterHireStatusView(reading: entry.reading,
                                showStatusText: false,
                                showEmoji: true)
            .font(.footnote)
        } currentValueLabel: {
            MeterDigitsView(reading: entry.reading,
                            style: .tiny,
                            showCurrencySymbol: false)
        }
        .gaugeStyle(.accessoryCircular)
    }
    
    private var lockScreenRectangularWidget: some View {
        HStack {
            CircularHireStatusGauge(reading: entry.reading)
            MeterDigitsView(reading: entry.reading,
                            style: .small,
                            showCurrencySymbol: true)
        }
    }
}

private extension View {
    @ViewBuilder func withWidgetContainerBackgroundColor(_ color: Color = .darkGrey1) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) { color }
        } else {
            self
        }
    }
    
    @ViewBuilder func borderedWidget(_ widgetContentView: () -> some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            widgetContentView()
        } else {
            Color.darkGrey1
                .overlay {
                    widgetContentView()
                     .padding()
                }
        }
    }
}


// MARK: - Preview
import ModelStubs

#Preview(as: .systemSmall) {
    EarningsMeterWidget()
} timeline: {
    MeterTimeLineEntry(date: .now,
                       reading: .notStarted,
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 5,
                       reading: .working(amountEarned: 100, progress: 0.25),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 10,
                       reading: .working(amountEarned: 200, progress: 0.5),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 15,
                       reading: .working(amountEarned: 300, progress: 0.75),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 15,
                       reading: .finished(amountEarned: 400),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
}
