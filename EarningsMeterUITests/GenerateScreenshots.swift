import XCTest

class GenerateScreenshots: XCTestCase {
    
    private var app: XCUIApplication!

    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UITests"]
        setupSnapshot(app)
        app.launch()
    }
    

    @MainActor
    func testGenerateAppScreenshots() throws {
        var screenshotNumber = 0
        func captureScreenshot(_ name: String) {
            screenshotNumber += 1
            let numPrefix = String(format: "%02d", screenshotNumber)
            snapshot("\(numPrefix)-\(name)")
        }
        
//        let iPhone = UIDevice.current.userInterfaceIdiom == .phone
        let iPad = UIDevice.current.userInterfaceIdiom == .pad
        
        XCUIDevice.shared.orientation = iPad ? .landscapeLeft : .portrait
        
        captureScreenshot("Setup")
        
        app.textFields["acc.id.rate.textfield"].firstMatch.tap()
        app.typeText("400")
        app.buttons["acc.id.save.button"].tap()
                
        captureScreenshot("DailyEarnings")
        
        app.buttons["acc.id.tab.title.accumulated.earnings"].firstMatch.tap()
        
        captureScreenshot("AccumulatedEarnings")
    }

}


extension XCUIElement {
    func tapUnhittable() {
        XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }
}
