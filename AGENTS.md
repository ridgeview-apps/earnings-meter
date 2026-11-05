# AGENTS.md

## Comments

Write self-documenting code. This applies to every file: Swift, Ruby, YAML, shell scripts.

- **Explain in code first:** before writing a comment, try a clearer name, or extract the expression into an explaining variable, e.g. `let isStillProcessing = …`.
- **Comment only what the code can't say:** a non-obvious *why*, a quirk of an external system, or an alternative that was rejected. Never restate what the code does.
- **Keep it short:** a line or so, above the code it explains.

## UI Tests (EarningsMeterUITests)

UI tests drive the app through page objects in `EarningsMeterUITests/Pages/`, one per screen, built on the generic `EarningsMeterUITests/Support/` layer. Each test launches the app with a `UITestLaunchConfiguration` (`Shared/UITesting/`), which fixes the clock and time zone and chooses the saved state (`UITestScenario.Seed`) the app starts with.

- **Naming:** the `Page` suffix is reserved for UI test page objects, e.g. `MeterSettingsPage`. App views are named `…Screen` (main target) or `…View` (PresentationViews), never `…Page`.
- **What a page holds:** element queries, actions that return the page they lead to (`earningsToday.tapSettingsButton() -> MeterSettingsPage`), and a `rootElement` that `waitingToAppear(in:)` waits for. Pages don't assert on content; tests do.
- **Action names:** name each action after the gesture and the element, e.g. `tapSaveButton()`, `longPressAmount()`, `swipeToDeleteX()`. Say "first" when it acts on the first of several matches (`tapFirstX()`). The return type says where the action leads, and the doc comment says why.
- **Finding elements:** by `AccessibilityID` (`Shared/UITesting/AccessibilityID.swift`), never by display text, so tests survive copy changes and localization. The exception is a system control with no identifier: use its SF Symbol image name if it has one, otherwise its label, in the narrowest scope that contains it, and explain why in a comment. Add an identifier only when a page needs it. Put a screen's root identifier on its `List` or `ScrollView`, not on a wrapping container, where it spreads to every child element.
- **Waiting:** use the `Support/` helpers (`waitToExist`, `tapWhenHittable`, …). They fail the test with a clear message rather than silently skipping a step.
- **Time:** views and screens read `@Environment(\.clock)`'s `clock.now`, never `Date.now` or `Calendar.isDateInToday(_:)`, so UI tests see the same time on every run.
- Add pages and actions only when a test needs them.
