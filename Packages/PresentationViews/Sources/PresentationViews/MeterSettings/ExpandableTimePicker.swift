import Foundation
import SwiftUI

struct ExpandableTimePicker: View {

    
    let title: LocalizedStringResource
    @Binding private(set) var selectedTime: Date
    @Binding private(set) var isExpanded: Bool
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            DatePicker("",
                       selection: $selectedTime,
                       displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(selectedTime.formatted(date: .omitted, time: .shortened))
                    .foregroundColor(isExpanded ? .blue : .primary)
            }
        }
    }
}


// MARK: - Previews

private struct WrapperView: View {
    
    @State var selectedTime: Date = .distantPast
    @State var isExpanded: Bool = false

    var body: some View {
        Form {
            ExpandableTimePicker(title: "Picker 1",
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
