import DataStores
import PresentationViews
import Models
import WidgetKit

struct MeterTimeLineProvider: TimelineProvider {
    typealias Entry = MeterTimeLineEntry
    
    let userDefaults: UserDefaults?
    
    private var meterSettings: MeterSettings {
        userDefaults?.userPreferences?.meterSettings ?? .placeholder
    }
    
    func placeholder(in context: Context) -> MeterTimeLineEntry {
        return .placeholder
    }
    
    // Called when a user is previewing the widget in the widget gallery or when the widget is in a transient state
    // (e.g. initial placement of the widget on screen)
    func getSnapshot(in context: Context, completion: @escaping (MeterTimeLineEntry) -> Void) {
        let snapshotEntry: MeterTimeLineEntry
        if context.isPreview {
            snapshotEntry = .placeholder
        } else {
            snapshotEntry = makeTimeLineEntry(at: .now)
        }
        completion(snapshotEntry)
    }
    
    // See: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
    //
    // Refreshes the widget by generating a timeline of events (i.e. points at which the widget will
    // re-render itself). Note: Apple restricts the number of "refreshes" (i.e. how often the method below
    // is called), NOT the number of timeline entries themselves.
    //
    func getTimeline(in context: Context, completion: @escaping (Timeline<MeterTimeLineEntry>) -> Void) {
        var entries: [MeterTimeLineEntry] = []
        let now = Date.now

        // 1. Generate a timeline entry for right now
        entries.append(makeTimeLineEntry(at: now))
        
        // 2. Generate 30 timeline entries (next 15 minutes, 2 per minute)
        let thirtySeconds = 30
        let firstScheduledEntry = now.roundedUp(toNearestSeconds: thirtySeconds)
        let fifteenMinutes = 15 * 60
        stride(from: 0, through: fifteenMinutes, by: thirtySeconds).forEach {
            if let readingTimestamp = Calendar.current.date(byAdding: .second, value: $0, to: firstScheduledEntry) {
                let scheduledEntry = makeTimeLineEntry(at: readingTimestamp)
                entries.append(scheduledEntry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd) // Request a new timeline after the last entry has fired
        completion(timeline)
    }
    
    private func makeTimeLineEntry(at date: Date) -> MeterTimeLineEntry {
        let calculator = MeterCalculator(meterSettings: meterSettings, calendar: .current)
        let reading = calculator.dailyReading(at: date)
        
        return MeterTimeLineEntry(date: date,
                                  reading: reading,
                                  meterSettings: meterSettings)
    }
}

struct MeterTimeLineEntry: TimelineEntry {
    let date: Date
    let reading: MeterReading
    let meterSettings: MeterSettings
    
    static let placeholder = MeterTimeLineEntry(date: .now,
                                                reading: .placeholder,
                                                meterSettings: .placeholder)
    
}

private extension MeterReading {
    static let placeholder = MeterReading.working(amountEarned: 25, progress: 0.25)
}

private extension MeterSettings {
    static let placeholder = MeterSettings(rate: .init(amount: 100, type: .daily),
                                           startTime: .init(hour: 9, minute: 0),
                                           endTime: .init(hour: 5, minute: 0),
                                           runAtWeekends: true)
}

private extension Date {
    func roundedUp(toNearestSeconds numberOfSeconds: Int) -> Date {
        let roundedTimeInterval = (timeIntervalSinceReferenceDate / TimeInterval(numberOfSeconds)).rounded(.up) * TimeInterval(numberOfSeconds)
        return Date(timeIntervalSinceReferenceDate: roundedTimeInterval)
    }
}
