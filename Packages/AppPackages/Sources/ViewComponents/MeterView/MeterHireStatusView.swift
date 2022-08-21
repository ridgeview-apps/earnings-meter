import SwiftUI
import Combine

public struct MeterHireStatusView: View {
    
    // MARK: - Data types
    
    public enum Status: Equatable {
        case free
        case atWork(progressValue: Double)
    }

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    // MARK: - Properties
    
    public let status: Status
    public let showStatusText: Bool
    public let showEmoji: Bool
    
    // MARK: - Initializers
    
    public init(status: MeterHireStatusView.Status,
                showStatusText: Bool = true,
                showEmoji: Bool = true) {
        self.status = status
        self.showStatusText = showStatusText
        self.showEmoji = showEmoji
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        HStack {
            if showEmoji {
                emojiText
            }
            if showStatusText {
                statusText
            }
        }
    }
    
    private var statusText: some View {
        Text(status.localizedStringKey, bundle: .module)
            .foregroundColor(.white)
    }
    
    @ViewBuilder private var emojiText: some View {
        switch status {
        case .free:
            Text("😀")
        case let .atWork(progressValue):
            Text(emoji(forProgressValue: progressValue))
        }
    }
    
    private func emoji(forProgressValue progressValue: Double) -> String {
        switch progressValue {
        case 0..<0.25:
            return "☹️"
        case 0.25..<0.5:
            return "😐"
        case 0.5..<0.75:
            return "🙂"
        default:
            return "😀"
        }
    }
}


// MARK: - Hire status localized text

extension MeterHireStatusView.Status {
    
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .free:
            return LocalizedStringKey("meter.hireStatus.free")
        case .atWork:
            return LocalizedStringKey("meter.hireStatus.atWork")
        }
    }
}


// MARK: - Previews

//#if DEBUG
struct MeterHireStatusView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            MeterHireStatusView(status: .atWork(progressValue: 0.1))
            MeterHireStatusView(status: .atWork(progressValue: 0.3))
            MeterHireStatusView(status: .atWork(progressValue: 0.6))
            MeterHireStatusView(status: .atWork(progressValue: 0.9))
            MeterHireStatusView(status: .free)
        }
        .background(Color.darkGrey1)
//        .previewOption(locale: .es) /*/ Spanish language */
//        .previewOption(contentSize: .extraExtraExtraLarge) /* XXL text */
    }
}

//#endif
