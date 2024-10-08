## Earnings Meter

Welcome to the Earnings Meter iOS app! This is a SwiftUI app and is available on [the app store](https://apps.apple.com/app/id1549867514#?platform=iphone).


## Screenshots

![](Docs/Images/iPhone-12-Pro-Max-02-MeterAtWork.png)
![](Docs/Images/iPhone-12-Pro-Max-04-Welcome.png)


## Getting Started

1. Install Xcode.
1. Select an iOS simulator and tap "Run"


## Architecture

The app uses the [MV architecture](https://azamsharp.com/2023/02/28/building-large-scale-apps-swiftui.html) but I have previously used both MVVM and the [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

> The original app's source code (developed using MVVM) is available [here](https://github.com/ridgeview-apps/earnings-meter/tree/legacy/mvvm).

Swift Package Manager is used to modularize the app as follows:

* `Models` - the main objects / models used globally across the app (e.g. `MeterSettings`, `MeterReading`)
* `DataStores` - the main data / business logic for the app
* `PresentationViews` - plain ("dumb") views / reusable components. These are purely for presentation purposes (hence perfect for SwiftUI previews). The components are typically just parts of a screen and contain no business logic.
* `Shared` - shared logic that can be used by ANY part of the app (i.e. any package or target - for example, `String`, `Date` extensions etc)

![](Docs/Images/swift-package-dependencies.png)

The main point to note is that the `PresentationViews` and `DataStores` packages are completely isolated from one another. The main app target itself is predominantly just composed of "screens" (which do all the heavy lifting and wire everything together - see example below).

> There are many ways to modularize an app, and I strongly recommend splitting up larger apps further into [bounded contexts](https://azamsharp.com/2023/02/28/building-large-scale-apps-swiftui.html#multiple-aggregate-models). The above structure, however, is a pretty good starting point and the packages themselves can be further subdivided as the app grows.

### Meter Reading example

Meter readings are a good example of data used in various parts of the app (e.g. main app screen, widgets):

* The `MeterReading` model is defined in the `Models` package.
* The `PresentationViews` package use this model to build reusable / previewable components
* The `DataStores` package contains business logic (`MeterCalculator`) which provides reading data to the main app or widgets.

> Note: The `PresentationViews` package used to be a completely standalone package with its own separate models. However I found myself frequently transforming from a `Models` "model" -> `PresentationViews` "model". So I found it much simpler to cut out the middle man and gave `PresentationViews` direct access to the `Models` package (any "presentation"-specific properties could simply be added via Swift extensions). This also makes data stubbing much simpler (for example `ModelStubs` contains lots of pre-configured data models which are perfect for SwiftUI previews and unit testing).

## Previews

App previews use stub data (see `ModelStubs.swift`) to generate the different screen states

![](Docs/Images/preview-example.png)

## Unit tests

Unit tests are written for the key parts of the app (model layer, data stores, presentation views) and each Swift package's unit tests can either be run in isolation or all at once with the main app target.

> Note: when using other approaches such as MVVM, pretty much all my tests were for view models. However, on SwiftUI, this always felt unnatural to me (i.e. view models served a great purpose in UIKit, RxSwift-world, but less so on SwiftUI). I took a closer look at what I was actually testing in the view models and found much of it was unnecessary (and the bits that *were* important could be easily extracted out & unit tested separately).

## Config

My preferred approach to config is to use `.xcconfig` files since they make it easier to handle merge conflicts (vs trying to resolve conflicts in a `.pbxproj` file). It also allows potentially sensitive data to be stored in separate `secret.xcconfig` files (which can be decrypted via [`git secret`](https://git-secret.io) to authorised users and CI environments).

The app's config files are set up as follows:

1. Debug (see [`Debug.xcconfig`](Config/Debug.xcconfig)). This is used for previews, unit tests and debugging the app on the simulator or a device and uses AUTOMATIC code-signing.
1. Release (see [`Release.xcconfig`](Config/Release.xcconfig)). This is used for CI  / App Store builds and uses MANUAL code-signing (see [Fastlane/CI](#fastlane-/-CI) below).
1. Additional xcconfig files are used to build the app for specific environments (e.g. `Beta.xcconfig`)

Note that the Xcconfig files themselves contain two "kinds" of config:

1. Build & Archive settings (e.g. code signing settings, compilation settings, bundle ID)
1. App config properties (API urls etc)

The app config properties are exposed in the `Info.plist` file and are loaded / referenced from Swift code (e.g. `AppConfig`, `WidgetConfig`).


## Fastlane / CI

* [`Fastlane`](https://fastlane.tools) is used to build and distribute the app.
* [`Fastlane match`](https://docs.fastlane.tools/actions/match/) is used to handle provisioning of CI builds. Although Apple has greatly improved its tools in recent years (e.g. automatic provisioning), I still find `match` to be a more mature and reliable solution, particularly in CI environments. For example, Apple's automatic provisioning still relies on having a user signed into Xcode via the Preferences pane, which can be flaky in a CI environment.
* Since [`Fastlane` now uses the App Store Connect API for most of its actions](https://docs.fastlane.tools/app-store-connect-api/), I have found it to be MUCH faster and easier to use (i.e. no longer need to worry about username/password credentials and all the headaches of 2-factor authentication in a CI environment).
* [`Fastlane snapshot`](https://docs.fastlane.tools/actions/snapshot/) is used to generate / upload screenshots to App Store Connect
* `Release` builds are used for uploading to [Testflight](https://www.google.com/search?client=safari&rls=en&q=testflight&ie=UTF-8&oe=UTF-8) and are eventually submitted for review.

Command examples

```ruby
fastlane unit_tests           # Run unit tests
fastlane add_badge_overlay    # Add a 'Beta' badge overlay
fastlane build                # Build / archive the app
fastlane distribute           # Distribute the app via TestFlight
fastlane snapshot             # Generate App Store screenshots
fastlane upload_screenshots   # Upload screenshots to App Store Connect
fastlane submit_for_review    # Submit the app for review
```
