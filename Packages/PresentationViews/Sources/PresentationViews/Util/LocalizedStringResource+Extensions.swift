import Foundation
import SwiftUI

// TOD0 - code-generate this file from JSON string catalog

public extension LocalizedStringResource {
    
    private static func moduleResource(_ key: String.LocalizationValue) -> LocalizedStringResource {
        .init(key, bundle: .module)
    }
    
    static var appInfoAppVersionTitle: LocalizedStringResource {
        moduleResource("appInfo.app.version.title")
    }

    static var appInfoContactUsTitle: LocalizedStringResource {
        moduleResource("appInfo.contact.us.title")
    }
    
    static var appInfoNavigationTitle: LocalizedStringResource {
        moduleResource("appInfo.navigation.title")
    }
    
    static var appInfoRateThisAppTitle: LocalizedStringResource {
        moduleResource("appInfo.rate.this.app.title")
    }
    
    static var contactUsBodyAppVersion: LocalizedStringResource {
        moduleResource("contact.us.body.app.version")
    }
    
    static var contactUsBodyDeviceInfo: LocalizedStringResource {
        moduleResource("contact.us.body.device.info")
    }

    static var contactUsBodyDiagnosticInfo: LocalizedStringResource {
        moduleResource("contact.us.body.diagnostic.info")
    }
    
    static var contactUsBodyLocaleInfo: LocalizedStringResource {
        moduleResource("contact.us.body.locale.info")
    }

    static var contactUsBodyOsVersion: LocalizedStringResource {
        moduleResource("contact.us.body.os.version")
    }

    static func contactUsSubject(_ subject: String) -> LocalizedStringResource {
        moduleResource("contact.us.subject \(subject)")
    }
    
    static var debugAppGroupHeader: LocalizedStringResource {
        moduleResource("debug.app.group.header")
    }
    
    static var debugAppGroupTitle: LocalizedStringResource {
        moduleResource("debug.app.group.title")
    }
    
    static var earningsSinceNavigationTitle: LocalizedStringResource {
        moduleResource("earnings.since.navigation.title")
    }
    
    static var earningsTodayNavigationTitle: LocalizedStringResource {
        moduleResource("earnings.today.navigation.title")
    }

    static var mailNotSupported: LocalizedStringResource {
        moduleResource("mail.not.supported")
    }

    static var meterDatePickerPleaseSelect: LocalizedStringResource {
        moduleResource("meter.date.picker.please.select")
    }
    
    static var meterDatePickerResetButtonTitle: LocalizedStringResource {
        moduleResource("meter.date.picker.reset.button.title")
    }

    static func meterHeaderEarningsSinceTitle(_ title: String) -> LocalizedStringResource {
        moduleResource("meter.header.earnings.since.title \(title)")
    }
    
    static var meterHeaderEarningsTodayTitle: LocalizedStringResource {
        moduleResource("meter.header.earnings.today.title")
    }

    static var meterHireStatusAtWork: LocalizedStringResource {
        moduleResource("meter.hireStatus.atWork")
    }

    static var meterHireStatusFree: LocalizedStringResource {
        moduleResource("meter.hireStatus.free")
    }
    
    static var settingsButtonTitleSave: LocalizedStringResource {
        moduleResource("settings.button.title.save")
    }
    
    static var settingsButtonTitleStart: LocalizedStringResource {
        moduleResource("settings.button.title.start")
    }
    
    static var settingsNavigationTitleEdit: LocalizedStringResource {
        moduleResource("settings.navigation.title.edit")
    }
    
    static var settingsNavigationTitleWelcome: LocalizedStringResource {
        moduleResource("settings.navigation.title.welcome")
    }

    static func settingsRateCalculated(_ rate: String) -> LocalizedStringResource {
        moduleResource("settings.rate.calculated \(rate)")
    }

    static func settingsRateCalculatedExact(_ rate: String) -> LocalizedStringResource {
        moduleResource("settings.rate.calculated.exact \(rate)")
    }

    static var settingsRatePickerAnnual: LocalizedStringResource {
        moduleResource("settings.rate.picker.annual")
    }

    static var settingsRatePickerDaily: LocalizedStringResource {
        moduleResource("settings.rate.picker.daily")
    }

    static var settingsRatePickerHour: LocalizedStringResource {
        moduleResource("settings.rate.picker.hour")
    }

    static var settingsRatePlaceholder: LocalizedStringResource {
        moduleResource("settings.rate.placeholder")
    }

    static var settingsRateTitle: LocalizedStringResource {
        moduleResource("settings.rate.title")
    }

    static var settingsRunAtWeekendsTitle: LocalizedStringResource {
        moduleResource("settings.runAtWeekends.title")
    }

    static var settingsWelcomeMessage: LocalizedStringResource {
        moduleResource("settings.welcome.message")
    }

    static var settingsWorkingHoursEndTimeTitle: LocalizedStringResource {
        moduleResource("settings.workingHours.endTime.title")
    }

    static var settingsWorkingHoursStartTimeTitle: LocalizedStringResource {
        moduleResource("settings.workingHours.startTime.title")
    }

    static var tabTitleAccumulatedEarnings: LocalizedStringResource {
        moduleResource("tab.title.accumulated.earnings")
    }

    static var tabTitleEarningsToday: LocalizedStringResource {
        moduleResource("tab.title.earnings.today")
    }
    
    static var widgetMeterConfigurationDescription: LocalizedStringResource {
        moduleResource("widget.meter.configuration.description")
    }
    
    static var widgetMeterConfigurationDisplayName: LocalizedStringResource {
        moduleResource("widget.meter.configuration.display.name")
    }
}
