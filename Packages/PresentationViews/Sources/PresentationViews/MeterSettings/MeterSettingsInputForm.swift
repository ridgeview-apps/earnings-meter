import Foundation
import Models

public enum MeterSettingsEditMode {
    case welcome
    case update
}

public struct MeterSettingsInputForm {
    public let editMode: MeterSettingsEditMode

    public var rateType: MeterSettings.Rate.RateType
    public var rateAmountFieldText: String
    public var startTime: Date
    public var endTime: Date
    public var runAtWeekends: Bool

    public var rateAmountFormat: FloatingPointFormatStyle<Double>
    public var calendar: Calendar
}


// MARK: - Form validation

public extension MeterSettingsInputForm {

    enum ValidationError: Error {
        case invalidRateAmount
        case invalidWorkingHours
    }
    var isValid: Bool {
        let validatedSettings = try? toMeterSettings()
        return validatedSettings != nil
    }

    var dailyRate: Double? { try? toMeterSettings()?.dailyRate }
    var hasValidWorkingHours: Bool { validateWorkingHours() }
    var hasOvernightWorkingHours: Bool {
        let startMeterTime = meterTime(for: startTime, calendar: calendar)
        let endMeterTime = meterTime(for: endTime, calendar: calendar)
        return endMeterTime.seconds < startMeterTime.seconds
    }

    func toMeterSettings() throws -> MeterSettings? {
        guard let validatedRateAmount = validateInputRateAmount() else {
            throw ValidationError.invalidRateAmount
        }
        guard validateWorkingHours() else {
            throw ValidationError.invalidWorkingHours
        }

        return .init(
            rate: .init(
                amount: validatedRateAmount,
                type: rateType
            ),
            startTime: meterTime(for: startTime, calendar: calendar),
            endTime: meterTime(for: endTime, calendar: calendar),
            runAtWeekends: runAtWeekends
        )
    }

    private func validateInputRateAmount() -> Double? {
        try? Double(rateAmountFieldText, format: rateAmountFormat).rounded(toDecimalPlaces: 2)
    }

    private func validateWorkingHours() -> Bool {
        let startMeterTime = meterTime(for: startTime, calendar: calendar)
        let endMeterTime = meterTime(for: endTime, calendar: calendar)
        return startMeterTime != endMeterTime
    }

    private func meterTime(for date: Date, calendar: Calendar) -> MeterSettings.MeterTime {
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = dateComponents.hour,
            let minute = dateComponents.minute
        else {
            assertionFailure("Unable to extract hour and date components for \(date)")
            return .init(hour: 0, minute: 0)
        }
        return .init(hour: hour, minute: minute)
    }
}


// MARK: - Welcome / Update states

public extension MeterSettingsInputForm {

    static func welcomeMode(
        calendar: Calendar = .current,
        today: Date = .now,
        rateAmountFormat: FloatingPointFormatStyle<Double> = .rateAmount
    ) -> MeterSettingsInputForm {
        let defaultStartTime = MeterSettings.MeterTime(hour: 9, minute: 0).toMeterDateTime(for: today, in: calendar)
        let defaultEndTime = MeterSettings.MeterTime(hour: 17, minute: 30).toMeterDateTime(for: today, in: calendar)

        return .init(
            editMode: .welcome,
            rateType: .daily,
            rateAmountFieldText: "",
            startTime: defaultStartTime,
            endTime: defaultEndTime,
            runAtWeekends: false,
            rateAmountFormat: rateAmountFormat,
            calendar: calendar
        )
    }

    static func updateMode(
        with settings: MeterSettings,
        calendar: Calendar = .current,
        today: Date = .now,
        rateAmountFormat: FloatingPointFormatStyle<Double> = .rateAmount
    ) -> MeterSettingsInputForm {
        return .init(
            editMode: .update,
            rateType: settings.rate.type,
            rateAmountFieldText: settings.rate.amount.formatted(rateAmountFormat),
            startTime: settings.startTime.toMeterDateTime(for: today, in: calendar),
            endTime: settings.endTime.toMeterDateTime(for: today, in: calendar),
            runAtWeekends: settings.runAtWeekends,
            rateAmountFormat: rateAmountFormat,
            calendar: calendar
        )
    }
}

public extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    static var rateAmount: Self { .number.precision(.fractionLength(2)) }
}


public extension MeterSettings {

    var defaultMeterSpeed: TimeInterval {
        let minMeterSpeed: TimeInterval = 1
        var desiredSpeed: TimeInterval = minMeterSpeed
        if dailyRate > 0 {
            desiredSpeed = workDayDuration / (dailyRate * 100)
        }
        return max(minMeterSpeed, desiredSpeed)
    }
}
