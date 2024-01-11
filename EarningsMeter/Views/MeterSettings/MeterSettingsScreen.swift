import DataStores
import Foundation
import Models
import SwiftUI
import PresentationViews

struct MeterSettingsScreen: View {

    @Environment(UserPreferencesDataStore.self) var userPreferences: UserPreferencesDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var inputForm: MeterSettingsInputForm = .welcomeMode()
    
    var body: some View {
        NavigationStack {
            MeterSettingsView(inputForm: $inputForm)
                .navigationTitle(navigationTitle)
                .interactiveDismissDisabled(userPreferences.isSetUpRequired)
                .toolbar {
                    if !userPreferences.isSetUpRequired {
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
        guard !userPreferences.isSetUpRequired,
              let savedMeterSettings = userPreferences.savedMeterSettings else {
            return
        }
        inputForm = .updateMode(with: savedMeterSettings)
    }
    
    private var navigationTitle: Text {
        switch inputForm.editMode {
        case .welcome:
            Text("settings.navigation.title.welcome")
        case .update:
            Text("settings.navigation.title.edit")
        }
    }
    
    private var saveButtonText: Text {
        switch inputForm.editMode {
        case .welcome:
            Text("settings.button.title.start")
        case .update:
            Text("settings.button.title.save")
        }
    }
    
    private var saveButton: some View {
        Button {
            if let updatedSettings = try? inputForm.toMeterSettings() {
                userPreferences.save(meterSettings: updatedSettings)
                dismiss()
            }
        } label: {
            saveButtonText
        }
        .accessibilityIdentifier("acc.id.save.button")
        .disabled(!inputForm.isValid)
    }
}
