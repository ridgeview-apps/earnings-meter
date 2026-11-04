import Shared
import XCTest

/// The tab bar on iPhone, or the top tab bar on iPad.
@MainActor
struct TabBar {

    /// The app's tabs, in the order it shows them.
    enum Tab: Int {
        case earningsToday, accumulatedEarnings

        var identifier: String {
            switch self {
            case .earningsToday: AccessibilityID.Tab.earningsToday
            case .accumulatedEarnings: AccessibilityID.Tab.accumulatedEarnings
            }
        }
    }

    let app: XCUIApplication

    func tapEarningsTodayTab() -> EarningsTodayPage {
        tap(.earningsToday)
        return .waitingToAppear(in: app)
    }

    func tapAccumulatedEarningsTab() -> AccumulatedEarningsPage {
        tap(.accumulatedEarnings)
        return .waitingToAppear(in: app)
    }

    private func tap(_ tab: Tab) {
        item(for: tab).tapWhenHittable()
    }

    private func item(for tab: Tab) -> XCUIElement {
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.descendants(matching: .any).matching(identifier: tab.identifier).firstMatch
        } else {
            // The iPhone tab bar's buttons have no identifiers until the selected tab first changes (see `AccessibilityID.Tab`)
            app.tabBars.buttons.element(boundBy: tab.rawValue)
        }
    }
}

extension Page {
    var tabBar: TabBar { TabBar(app: app) }
}
