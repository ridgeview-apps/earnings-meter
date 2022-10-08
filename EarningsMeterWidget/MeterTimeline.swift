import DataSources
import Model
import WidgetKit

struct MeterTimeLineProvider: TimelineProvider {
    typealias Entry = MeterTimeLineEntry
    
    let meterDataSource: MeterSettingsDataSource
    
    init(meterDataSource: MeterSettingsDataSource) {
        self.meterDataSource = meterDataSource
    }
    
    func placeholder(in context: Context) -> MeterTimeLineEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MeterTimeLineEntry) -> Void) {
        let timeLineEntry: MeterTimeLineEntry
        if context.isPreview {
            timeLineEntry = .placeholder
        } else {
            let now = Date()
            timeLineEntry =  makeTimeLineEntry(at: now) ?? .placeholder
        }
        completion(timeLineEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MeterTimeLineEntry>) -> Void) {
        var entries: [MeterTimeLineEntry] = []
        
        let now = Date()
        if let currentReading = makeTimeLineEntry(at: now) {
            entries.append(currentReading)
        }
        
        if let oneMinuteFromNow = Calendar.current.date(byAdding: .minute, value: 1, to: now),
           let nextScheduledReading = makeTimeLineEntry(at: oneMinuteFromNow) {
            entries.append(nextScheduledReading)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    
    private func makeTimeLineEntry(at date: Date) -> MeterTimeLineEntry?  {
        meterDataSource.load()
        
        let meterSettings = meterDataSource.meterSettings ?? .placeholder
        
        let calculator = MeterCalculator(meterSettings: meterSettings)
        let reading = calculator.calculateReading(at: date)
        
        return MeterTimeLineEntry(date: date,
                                  reading: reading,
                                  meterSettings: meterSettings)
    }
}

struct MeterTimeLineEntry: TimelineEntry {
    let date: Date
    let reading: MeterCalculator.Reading
    let meterSettings: MeterSettings
    
    static let placeholder = MeterTimeLineEntry(date: Date(),
                                               reading: .placeholder,
                                               meterSettings: .placeholder)
    
}

extension MeterCalculator.Reading {
    static let placeholder = MeterCalculator.Reading(amountEarned: 25, progress: 0.25, status: .atWork)
}

extension MeterSettings {
    static let placeholder = MeterSettings(rate: .init(amount: 100, type: .daily),
                                           startTime: .init(hour: 9, minute: 0),
                                           endTime: .init(hour: 5, minute: 0),
                                           runAtWeekends: true)
}
