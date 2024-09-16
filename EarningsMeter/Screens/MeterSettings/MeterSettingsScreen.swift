import DataStores
import Foundation
import Models
import PresentationViews
import Shared
import SwiftUI

struct MeterSettingsScreen: View {

    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: .sharedTargetStorage)
    private var userPreferences: UserPreferences = .empty
    
    @Environment(\.dismiss) var dismiss
    
    @State private var inputForm: MeterSettingsInputForm = .welcomeMode()
    
    var body: some View {
        NavigationStack {
            MeterSettingsView(inputForm: $inputForm)
                .navigationTitle(navigationTitle)
                .interactiveDismissDisabled(userPreferences.needsOnboarding)
                .toolbar {
                    if !userPreferences.needsOnboarding {
                        ToolbarCloseButton(placement: .topBarLeading)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        saveButton
                    }
                }
                .task {
                    prepareEditMode()
                }
        }
    }
    
    private func prepareEditMode() {
        guard !userPreferences.needsOnboarding,
              let savedMeterSettings = userPreferences.meterSettings else {
            return
        }
        inputForm = .updateMode(with: savedMeterSettings)
    }
    
    private var navigationTitle: Text {
        switch inputForm.editMode {
        case .welcome:
            Text(.settingsNavigationTitleWelcome)
        case .update:
            Text(.settingsNavigationTitleEdit)
        }
    }
    
    private var saveButtonText: Text {
        switch inputForm.editMode {
        case .welcome:
            Text(.settingsButtonTitleStart)
        case .update:
            Text(.settingsButtonTitleSave)
        }
    }
    
    private var saveButton: some View {
        Button {
            if let updatedSettings = try? inputForm.toMeterSettings() {
                userPreferences.meterSettings = updatedSettings
                dismiss()
            }
        } label: {
            saveButtonText
        }
        .accessibilityIdentifier("acc.id.save.button")
        .disabled(!inputForm.isValid)
    }
}
