import AppCenterCrashes

struct DebugSettings {

    static func testCrashReporting() {
        Crashes.generateTestCrash()
    }
    
}
