import PresentationViews
import Shared
import SwiftUI

// MARK: - Settings button

struct ToolbarSettingsButton: ToolbarContent {

    var placement: ToolbarItemPlacement = .automatic
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            ImageButton(imageName: "gearshape", action: action)
                .accessibilityIdentifier(AccessibilityID.Toolbar.settingsButton)
        }
    }
}

// MARK: - Info button

struct ToolbarInfoButton: ToolbarContent {

    var placement: ToolbarItemPlacement = .automatic
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            ImageButton(imageName: "info.circle", action: action)
                .accessibilityIdentifier(AccessibilityID.Toolbar.infoButton)
        }
    }
}

// MARK: - Close button

struct ToolbarCloseButton: ToolbarContent {

    typealias ShouldDismissHandler = () -> Bool
    typealias DidDismissHandler = () -> Void

    var placement: ToolbarItemPlacement = .automatic
    var onShouldDismiss: ShouldDismissHandler = { true }
    var onDidDismiss: DidDismissHandler = {}

    @Environment(\.dismiss) var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            ImageButton(imageName: "xmark") {
                if onShouldDismiss() {
                    dismiss()
                    onDidDismiss()
                }
            }
            .accessibilityLabel(Text(L10n.toolbarCloseButtonAccessibilityLabel))
            .accessibilityHint(Text(L10n.toolbarCloseButtonAccessibilityHint))
            .accessibilityIdentifier(AccessibilityID.Toolbar.closeButton)
        }
    }
}


extension View {

    func withToolbarSettingsButton(
        placement: ToolbarItemPlacement = .automatic,
        action: @escaping () -> Void
    ) -> some View {
        toolbar {
            ToolbarSettingsButton(placement: placement, action: action)
        }
    }

    func withToolbarInfoButton(placement: ToolbarItemPlacement = .automatic, action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarInfoButton(placement: placement, action: action)
        }
    }

    func withToolbarCloseButton(
        placement: ToolbarItemPlacement,
        onShouldDismiss: @escaping ToolbarCloseButton.ShouldDismissHandler = { true },
        onDidDismiss: @escaping ToolbarCloseButton.DidDismissHandler = {}
    ) -> some View {
        toolbar {
            ToolbarCloseButton(
                placement: placement,
                onShouldDismiss: onShouldDismiss,
                onDidDismiss: onDidDismiss
            )
        }
    }
}


// MARK: - ToolbarImageButton

private struct ImageButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .imageScale(.large)
        }
    }
}
