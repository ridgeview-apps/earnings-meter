import Foundation

/// The accessibility identifiers UI tests find elements by. The app and PresentationViews set them and the UI tests
/// query them, so both sides share one spelling.
public enum AccessibilityID {

    /// On iPhone, the tab bar's buttons only get these once the selected tab first changes (seen on iOS 27), so UI
    /// tests find iPhone tabs by position.
    public enum Tab {
        public static let earningsToday = "tab.earningsToday"
        public static let accumulatedEarnings = "tab.accumulatedEarnings"
    }

    public enum Toolbar {
        public static let settingsButton = "toolbar.settingsButton"
        public static let infoButton = "toolbar.infoButton"
        public static let closeButton = "toolbar.closeButton"
    }

    public enum Meter {
        public static let earningsTodayHeader = "meter.earningsTodayHeader"
        public static let accumulatedEarningsHeader = "meter.accumulatedEarningsHeader"
        /// The amount earned, without its currency symbol.
        public static let amount = "meter.amount"
    }

    public enum MeterSettings {
        public static let list = "meterSettings.list"
        public static let rateField = "meterSettings.rateField"
        public static let rateTypePicker = "meterSettings.rateTypePicker"
        public static let rateValidationError = "meterSettings.rateValidationError"
        public static let startTime = "meterSettings.startTime"
        public static let endTime = "meterSettings.endTime"
        public static let workingHoursInvalid = "meterSettings.workingHoursInvalid"
        public static let workingHoursOvernight = "meterSettings.workingHoursOvernight"
        public static let runAtWeekendsToggle = "meterSettings.runAtWeekendsToggle"
        public static let saveButton = "meterSettings.saveButton"
        public static let discardChangesButton = "meterSettings.discardChangesButton"
    }
}
