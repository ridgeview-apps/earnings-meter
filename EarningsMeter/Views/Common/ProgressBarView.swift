import SwiftUI

struct ProgressBarView: View {
    
    let leftLabelText: String
    let rightLabelText: String
    var value: Double
    
    private(set) var enabledTextColor: Color = .primary
    private(set) var disabledTextColor: Color = .disabledText
    
    private(set) var isEnabled: Bool = true
    
    private let progressBarHeight: CGFloat = 4
    
    var body: some View {
        HStack(spacing: 20) {
            Text(leftLabelText)
                .foregroundColor(textColor)
                .font(.subheadline)
            
            centralProgressBar
                .frame(height: 14)
            
            Text(rightLabelText)
                .foregroundColor(textColor)
                .font(.subheadline)
        }
        .padding()
        .frame(height: 30)
    }
    
    private var centralProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    self.backgroundFill(width: geometry.size.width)
                    self.progressFill(maxWidth: geometry.size.width)
                }
                .cornerRadius(20)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(self.progressFillColor,
//                                lineWidth: self.progressBarStrokeWidth)
//                        .frame(width: geometry.size.width,
//                               height: progressBarHeight)
//                )
//
                Group {
                    if self.isEnabled {
                        Text(self.progressEmoji)
                            .font(.system(size: 18))
                            .offset(x: self.emojiOffset(maxWidth:  geometry.size.width))
                    } else {
                        Text(self.progressEmoji)
                            .font(.system(size: 18))
                            .hidden()
                    }
                }.frame(height: 14)
            }
            
        }
    }
    
    private var progressBarStrokeWidth: CGFloat {
        isEnabled ? 1 : 0
    }
    
    private var textColor: Color {
        isEnabled ? enabledTextColor : disabledTextColor
    }
    
    private var progressFillColor: Color {
        isEnabled ? .redOne : .disabledText
    }
    
    private var progressBackgroundFillColor: Color {
        isEnabled ? Color.greyOne : .disabledText
    }
    
    private func progressFillWidth(for fullWidth: CGFloat) -> CGFloat {
        return min(CGFloat(self.value) * fullWidth, fullWidth)
    }
    
    private func emojiOffset(maxWidth: CGFloat) -> CGFloat {
        return progressFillWidth(for: maxWidth) - 14
    }
    
    private func backgroundFill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(progressBackgroundFillColor)
            .frame(width: width, height: progressBarHeight)
    }
    
    private func progressFill(maxWidth: CGFloat) -> some View {
        Rectangle()
            .frame(width: self.progressFillWidth(for: maxWidth),
                   height: progressBarHeight)
            .foregroundColor(progressFillColor)
    }
    
    private var progressEmoji: String {
        switch value {
        case 0..<0.25:
            return "☹️"
        case 0.25..<0.5:
            return "😐"
        case 0.5..<0.75:
            return "😐"
        default:
            return "😃"            
        }
    }
}

// MARK: - Previews
#if DEBUG
struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 0.01,
                            enabledTextColor: .white)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 0.24,
                            enabledTextColor: .white)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 0.49,
                            enabledTextColor: .white)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 0.74,
                            enabledTextColor: .white)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 1,
                            enabledTextColor: .white)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 0,
                            enabledTextColor: .white,
                            isEnabled: false)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 1,
                            enabledTextColor: .white,
                            isEnabled: false)
            ProgressBarView(leftLabelText: "09:00",
                            rightLabelText: "17:00",
                            value: 1,
                            enabledTextColor: .white,
                            isEnabled: false)
        }
        .background(Color.cyan)
    }
}
#endif
