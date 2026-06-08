import SwiftUI

struct TabContentScreenModifier: ViewModifier {

    @State private var activeSheetItem: TabContentSheetItem?

    func body(content: Content) -> some View {
        NavigationStack {
            content
                .sheet(item: $activeSheetItem) {
                    show(sheetItem: $0)
                }
                .withToolbarInfoButton(placement: .topBarLeading) {
                    activeSheetItem = .info
                }
                .withToolbarSettingsButton(placement: .topBarTrailing) {
                    activeSheetItem = .settings
                }
        }
    }

    @ViewBuilder private func show(sheetItem: TabContentSheetItem) -> some View {
        switch sheetItem {
        case .info:
            AppInfoScreen()
        case .settings:
            MeterSettingsScreen()
        }
    }
}

extension View {

    func tabContentScreen() -> some View {
        modifier(
            TabContentScreenModifier()
        )
    }
}
