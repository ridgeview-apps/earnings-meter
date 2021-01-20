import Foundation
import SwiftUI
import Combine

struct ExpandableTimePicker: View {
    
    let title: LocalizedStringKey
    @Binding private(set) var selectedTime: Date
    @Binding private(set) var isExpanded: Bool
    private(set) var timeFormatter = DateFormatter.shortTimeStyle
    
    var body: some View {
        Group {
            Button(action: {
                withAnimation {
                    self.isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(selectedTimeText)
                        .foregroundColor(isExpanded ? .blue : .primary)
                }
            }
            if isExpanded {
                DatePicker("",
                           selection: $selectedTime,
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            }
        }
    }
    
    private var selectedTimeText: String {
        return timeFormatter.string(from: selectedTime)
    }

}

// MARK: - Previews
#if DEBUG
struct ExpandableTimePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        ExpandablePickerPreview()
    }
    
    struct ExpandablePickerPreview: View {
        
        @State private var picker1SelectedTime: Date = .distantPast
        @State private var isPicker1Expanded: Bool = false
        @State private var picker2SelectedTime: Date = .distantPast
        @State private var isPicker2Expanded: Bool = false

        var body: some View {
            Group {
                Form {
                    ExpandableTimePicker(title: "Picker 1",
                                         selectedTime: $picker1SelectedTime,
                                         isExpanded: $isPicker1Expanded)
                }
                Form {
                    ExpandableTimePicker(title: "Picker 1",
                                         selectedTime: $picker1SelectedTime,
                                         isExpanded: $isPicker1Expanded)
                
                }
                .previewOption(colorScheme: .dark)

            }
        }
    }
}
#endif
