import AppConfig
import Combine
import DataSources
import Intents
import Model
import SwiftUI
import ViewComponents
import SharedViewStates
import WidgetKit

private final class WidgetBundlePin {}

@main
struct EarningsMeterWidget: Widget {
    let kind: String = "EarningsMeterWidget"
    
    private let settingsDataSource: MeterSettingsDataSource
    
    init() {
        let appConfig = AppConfig.loaded(fromBundle: Bundle(for: WidgetBundlePin.self))
        self.init(settingsDataSource: .real(appGroupName: appConfig.appGroupName))
    }
    
    init(settingsDataSource: MeterSettingsDataSource) {
        self.settingsDataSource = settingsDataSource
    }
    
    // MARK: - Layout
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: MeterTimeLineProvider(meterDataSource: settingsDataSource)) { entry in
            meterWidgetView(forTimelineEntry: entry)
        }
        .supportedFamilies([.systemSmall,
                            .systemMedium,
                            .accessoryCircular,
                            .accessoryRectangular])
        .configurationDisplayName(Text("meter.widget.configuration.display.name"))
        .description(Text("meter.widget.configuration.description"))
    }
    
    // MARK: - Layout views
    
    private func meterWidgetView(forTimelineEntry entry: MeterTimeLineEntry) -> MeterWidgetView {
        let viewState = MeterViewState(settings: entry.meterSettings, reading: entry.reading)
        
        return MeterWidgetView(isEnabled: viewState.isEnabled,
                               amountEarned: viewState.reading.amountEarned,
                               hireStatus: viewState.hireStatus,
                               workStartTimeText: viewState.startTimeText,
                               workEndTimeText: viewState.endTimeText,
                               progressBarValue: viewState.reading.progress)
    }
}
