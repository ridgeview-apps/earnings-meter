struct MeterSettings: Codable, Equatable {
    let dailyRate: Double
    let startTime: MeterTime
    let endTime: MeterTime
    let runAtWeekends: Bool
}
