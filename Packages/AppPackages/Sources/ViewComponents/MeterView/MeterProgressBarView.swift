import SwiftUI

public struct MeterProgressBarView: View {
    
    // MARK: - Properties
    
    public let leftLabelText: String
    public let rightLabelText: String
    public let value: Double
    public let showTextLabels: Bool
    public let isEnabled: Bool
    
    
    // MARK: - Init
    
    public init(leftLabelText: String,
                rightLabelText: String,
                value: Double,
                showTextLabels: Bool,
                isEnabled: Bool) {
        self.leftLabelText = leftLabelText
        self.rightLabelText = rightLabelText
        self.value = value
        self.showTextLabels = showTextLabels
        self.isEnabled = isEnabled
    }
    
    
    
    private let disabledFillColor = Color.redTwo
    
    public var body: some View {
        
        Gauge(value: gaugeValue) {
            Text("")
        } currentValueLabel: {
            Text("")
        } minimumValueLabel: {
            Text(showTextLabels ? leftLabelText : "")
        } maximumValueLabel: {
            Text(showTextLabels ? rightLabelText : "")
        }
        .font(.subheadline)
        .foregroundColor(isEnabled ? .white : disabledFillColor)
        .tint(isEnabled ? .redOne : disabledFillColor)
        .gaugeStyle(.accessoryLinearCapacity)
    }
    
    private var gaugeValue: Double {
        let disabledFillValue = 1.0 //
        return isEnabled ? value : disabledFillValue
    }
}


// MARK: - Previews

#if DEBUG

struct ProgressBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            nineToFiveView(withProgress: 0.01)
            nineToFiveView(withProgress: 0.24)
            nineToFiveView(withProgress: 0.49)
            nineToFiveView(withProgress: 0.74)
            nineToFiveView(withProgress: 1)
            nineToFiveView(withProgress: 0, isEnabled: false)
            nineToFiveView(withProgress: 1, isEnabled: false)
            nineToFiveView(withProgress: 0.74, showTextLabels: false)
        }
        .background(Color.darkGrey1)
        .previewOption(locale: .en)
        .previewOption(contentSize: .large)
        .previewOption(colorScheme: .light)
    }

     static func nineToFiveView(
        withProgress progressValue: Double,
        isEnabled: Bool = true,
        showTextLabels: Bool = true
     ) -> MeterProgressBarView {
        .init(
            leftLabelText: "09:00",
            rightLabelText: "17:00",
            value: progressValue,
            showTextLabels: showTextLabels,
            isEnabled: isEnabled
        )
    }
}
#endif
