import XCTest

class GenerateScreenshots: XCTestCase {
    
    private var app: XCUIApplication!
    private var isRunningOnIPhone = false
    private var isRunningOnIPad = false

    override func setUp() {
        super.setUp()
        
        isRunningOnIPhone = UIDevice.current.userInterfaceIdiom == .phone
        isRunningOnIPad = UIDevice.current.userInterfaceIdiom == .pad

        XCUIDevice.shared.orientation = isRunningOnIPad ? .landscapeLeft : .portrait

        // Use accessibility ids where possible to tap buttons etc e.g.
        //   app.buttons["Status"].tap()
        //   app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testScreenshot_meterViewBeforeWork() throws {
        app = .launched(with: .meterViewBeforeWork, snapshotMode: true)
        snapshot("01-MeterBeforeWork")
    }
    
    func testScreenshot_meterViewAtWork() throws {
        app = .launched(with: .meterViewAtWork, snapshotMode: true)
        snapshot("02-MeterAtWork")
    }
    
    func testScreenshot_meterViewAfterWork() throws {
        app = .launched(with: .meterViewAfterWork, snapshotMode: true)
        snapshot("03-MeterAfterWork")
    }
    
    func testScreenshot_welcomeView() throws {
        guard isRunningOnIPhone else { return } // Ignore this screenshot on iPad
        
        app = .launched(with: .welcomeView, snapshotMode: true)
        snapshot("04-Welcome")
    }

}


extension XCUIApplication {
    
    static func launched(with testScenario: UITestScenario,
                         snapshotMode: Bool = false) -> XCUIApplication {
        
        let app = XCUIApplication()
        app.launchArguments = ["UITests"]
        app.launchEnvironment["uiTestScenario"] = testScenario.rawValue
        if snapshotMode {
            setupSnapshot(app)
        }
        app.launch()
        return app
    }
}
