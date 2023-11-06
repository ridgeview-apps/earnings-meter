import SwiftUI

struct TabContentScreenModifier: ViewModifier {
    
    let imageName: String
    let title: LocalizedStringKey
    let accessibilityID: String
    
    @Binding var activeSheetItem: TabContentSheetItem?
    
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
        .styledTabItem(
            imageName: imageName,
            title: title,
            accessibilityID: accessibilityID
        )
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
    
    func tabContentScreen(imageName: String, 
                          title: LocalizedStringKey,
                          accessibilityID: String,
                          activeSheetItem: Binding<TabContentSheetItem?>) -> some View {
        modifier(TabContentScreenModifier(imageName: imageName,
                                          title: title,
                                          accessibilityID: accessibilityID,
                                          activeSheetItem: activeSheetItem))
    }
}
