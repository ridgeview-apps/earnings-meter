import Foundation
import SwiftUI

struct ExpandableTimePicker: View {

    
    let title: LocalizedStringResource
    let accessibilityIdentifier: String
    @Binding private(set) var selectedTime: Date
    @Binding private(set) var isExpanded: Bool
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            DatePicker(title,
                       selection: $selectedTime,
                       displayedComponents: .hourAndMinute)
            .labelsHidden()
            .datePickerStyle(.wheel)
            .accessibilityIdentifier("\(accessibilityIdentifier).picker")
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(selectedTime.formatted(date: .omitted, time: .shortened))
                    .foregroundColor(isExpanded ? Color.accentColor : .primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(selectedTime.formatted(date: .omitted, time: .shortened)))
        .accessibilityHint(isExpanded ? Text(.settingsWorkingHoursCollapseHint) : Text(.settingsWorkingHoursExpandHint))
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}


// MARK: - Previews

private struct WrapperView: View {
    
    @State var selectedTime: Date = .distantPast
    @State var isExpanded: Bool = false

    var body: some View {
        Form {
            ExpandableTimePicker(title: "Picker 1",
                                 accessibilityIdentifier: "acc.id.preview.time.picker",
                                 selectedTime: $selectedTime,
                                 isExpanded: $isExpanded)
        }
    }
}

#Preview("Collapsed state") {
    WrapperView()
}

#Preview("Expanded state") {
    WrapperView(isExpanded: true)
}
