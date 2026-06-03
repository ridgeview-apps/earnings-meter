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
    @State private var initialInputFormSnapshot: InputFormSnapshot?
    @State private var showDiscardChangesDialog = false
    
    var body: some View {
        NavigationStack {
            MeterSettingsView(inputForm: $inputForm)
                .navigationTitle(navigationTitle)
                .interactiveDismissDisabled(userPreferences.needsOnboarding)
                .toolbar {
                    if !userPreferences.needsOnboarding {
                        ToolbarCloseButton(placement: .topBarLeading,
                                           onShouldDismiss: onCloseButtonShouldDismiss)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        saveButton
                    }
                }
                .confirmationDialog(Text(.settingsDiscardChangesTitle),
                                    isPresented: $showDiscardChangesDialog,
                                    titleVisibility: .visible) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(.settingsDiscardChangesConfirmButton)
                    }
                    Button(role: .cancel) {
                    } label: {
                        Text(.settingsDiscardChangesCancelButton)
                    }
                } message: {
                    Text(.settingsDiscardChangesMessage)
                }
                .task {
                    prepareEditMode()
                }
        }
    }
    
    private func prepareEditMode() {
        guard !userPreferences.needsOnboarding,
              let savedMeterSettings = userPreferences.meterSettings else {
            initialInputFormSnapshot = .init(inputForm)
            return
        }
        inputForm = .updateMode(with: savedMeterSettings)
        initialInputFormSnapshot = .init(inputForm)
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

    private func onCloseButtonShouldDismiss() -> Bool {
        if hasUnsavedChanges {
            showDiscardChangesDialog = true
            return false
        }
        return true
    }

    private var hasUnsavedChanges: Bool {
        guard let initialInputFormSnapshot else {
            return false
        }
        return initialInputFormSnapshot != .init(inputForm)
    }
}

private struct InputFormSnapshot: Equatable {
    let rateType: MeterSettings.Rate.RateType
    let rateAmountFieldText: String
    let startTime: Date
    let endTime: Date
    let runAtWeekends: Bool
    let emojisEnabled: Bool

    init(_ inputForm: MeterSettingsInputForm) {
        self.rateType = inputForm.rateType
        self.rateAmountFieldText = inputForm.rateAmountFieldText
        self.startTime = inputForm.startTime
        self.endTime = inputForm.endTime
        self.runAtWeekends = inputForm.runAtWeekends
        self.emojisEnabled = inputForm.emojisEnabled
    }
}
