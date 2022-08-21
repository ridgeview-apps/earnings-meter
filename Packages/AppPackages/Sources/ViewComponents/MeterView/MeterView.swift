import SwiftUI
import Combine

public struct MeterView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    // MARK: - Properties
    
    public let isEnabled: Bool
    public let amountEarned: Double
    public let hireStatus: MeterHireStatusView.Status
    public let workStartTimeText: String
    public let workEndTimeText: String
    public let progressBarValue: Double
    
    
    // MARK: - Initializers
    
    public init(isEnabled: Bool,
                amountEarned: Double, 
                hireStatus: MeterHireStatusView.Status,
                workStartTimeText: String, 
                workEndTimeText: String, 
                progressBarValue: Double) {
        self.isEnabled = isEnabled
        self.amountEarned = amountEarned
        self.hireStatus = hireStatus
        self.workStartTimeText = workStartTimeText
        self.workEndTimeText = workEndTimeText
        self.progressBarValue = progressBarValue
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 12) {
            titleView
            VStack(spacing: 4) {
                digitsView
                progressBarView
                hireStatusView
            }            
        }
        .padding(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
        .background(Color.darkGrey1)
        .roundedBorder(.white, cornerRadius: 16, lineWidth: 4)
        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Layout views
    
    private var titleView: some View {
        Text("meter.header.earnings.today.title", bundle: .module)
            .font(.title2)
            .shrinkableSingleLine()
            .padding([.leading, .trailing], 20)
            .foregroundColor(.white)
    }
    
    private var digitsView: some View {
        MeterDigitsView(
            amount: amountEarned,
            isEnabled: isEnabled,
            style: hasCompactWidth ? .medium : .large
        )
    }
    
    private var progressBarView: some View {
        MeterProgressBarView(
            leftLabelText: workStartTimeText,
            rightLabelText: workEndTimeText,
            value: progressBarValue,
            showTextLabels: true,
            isEnabled: isEnabled
        )
        .frame(maxWidth: 450)
    }
    
    private var hireStatusView: some View {
        MeterHireStatusView(status: hireStatus)
            .font(.subheadline)
    }
        
    private var hasCompactWidth: Bool { horizontalSizeClass == .compact }

}


// MARK: - Previews

//#if DEBUG
struct MeterView_Previews: PreviewProvider {
    
    static func nineToFivePreview(isEnabled: Bool = true,
                                  amount: Double = 123.45,
                                  hireStatus: MeterHireStatusView.Status = .free,
                                  progressBarValue: Double = 0.25) -> some View {
        MeterView(
            isEnabled: isEnabled,
            amountEarned: amount,
            hireStatus: hireStatus,
            workStartTimeText: "09:00",
            workEndTimeText: "17:00",
            progressBarValue: progressBarValue
        )
        .padding([.leading, .trailing], 16)
    }
    
    static var previews: some View {
        Font.registerCustomFonts()
        
        return ScrollView {
            nineToFivePreview(isEnabled: false, hireStatus: .free, progressBarValue: 0)
            nineToFivePreview(isEnabled: false, hireStatus: .free, progressBarValue: 0)
            nineToFivePreview(isEnabled: false, hireStatus: .free, progressBarValue: 1)
            nineToFivePreview(isEnabled: true, hireStatus: .atWork(progressValue: 0.1))
            
        }
//        .previewOption(locale: .es) /*/ Spanish language */
    }
}

//#endif
