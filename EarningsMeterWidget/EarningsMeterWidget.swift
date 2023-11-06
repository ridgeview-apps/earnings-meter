import AppConfig
import Combine
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
    
    private let userPreferences: UserPreferencesDataStore
    private let appConfig: AppConfig
    private let timelineProvider: MeterTimeLineProvider
    
    init() {
        let appConfig = AppConfig.loadedFromInfoPlist(inBundle: Bundle(for: WidgetBundlePin.self))
        self.init(appConfig: appConfig,
                  userPreferences: .real(sharedAppGroupName: appConfig.appGroupName))
    }
    
    init(appConfig: AppConfig,
         userPreferences: UserPreferencesDataStore) {
        self.appConfig = appConfig
        self.userPreferences = userPreferences
        self.timelineProvider = MeterTimeLineProvider(userPreferences: userPreferences)
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
        .configurationDisplayName(Text("meter.widget.configuration.display.name"))
        .description(Text("meter.widget.configuration.description"))
    }
    
    @ViewBuilder private var widgetOverlayTitle: some View {
        if let widgetOverlayTitle = appConfig.widgetOverlayTitle, !widgetOverlayTitle.isEmpty {
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
#if DEBUG
@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    EarningsMeterWidget(appConfig: .stub, userPreferences: .stub())
} timeline: {
    MeterTimeLineEntry(date: .now,
                       reading: .init(amountEarned: 0, status: .beforeWork),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 5,
                       reading: .init(amountEarned: 100, status: .atWork(progress: 0.25)),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 10,
                       reading: .init(amountEarned: 200, status: .atWork(progress: 0.5)),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 15,
                       reading: .init(amountEarned: 300, status: .atWork(progress: 0.75)),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
    MeterTimeLineEntry(date: .now + 15,
                       reading: .init(amountEarned: 400, status: .afterWork),
                       meterSettings: ModelStubs.dayTime_0900_to_1700())
}
#endif
