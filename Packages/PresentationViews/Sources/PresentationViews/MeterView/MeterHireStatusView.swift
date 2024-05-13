import Models
import SwiftUI

public struct MeterHireStatusView: View {
    
    // MARK: - Data types
    
    public enum Status: Equatable {
        case free
        case atWork
    }

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    // MARK: - Properties
    
    public let status: Status
    public let progressValue: Double
    public let showStatusText: Bool
    public let showEmoji: Bool
    public let showLiveStatusImage: Bool
    
    
    // MARK: - Body
    
    public var body: some View {
        HStack {
            if showEmoji {
                Text(statusEmoji)
            }
            if showStatusText {
                statusText
            }
            if status == .atWork && showLiveStatusImage {
                Image(systemName: "circle.inset.filled")
                    .foregroundColor(.white)
                    .pulsatingSymbol()
            }

        }
    }
    
    private var statusText: some View {
        Text(status.localizedStringKey, bundle: .module)
            .textCase(.uppercase)
            .foregroundColor(.white)
    }
    
    private var statusEmoji: String {
        switch status {
        case .atWork where progressValue < 0.25:
            return "☹️"
        case .atWork where progressValue < 0.5:
            return "😐"
        case .atWork where progressValue < 0.75:
            return "🙂"
        default:
            return "😀" // Free or at end of working day
        }
    }
}


// MARK: - Convenience init

public extension MeterHireStatusView {

    init(reading: MeterReading,
         showStatusText: Bool = true,
         showEmoji: Bool = true,
         showLiveStatusImage: Bool = false) {
        self.status = reading.hireStatus
        self.progressValue = reading.progress
        self.showStatusText = showStatusText
        self.showEmoji = showEmoji
        self.showLiveStatusImage = showLiveStatusImage
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

private extension MeterReading {
   
    var hireStatus: MeterHireStatusView.Status {
        switch self.status {
        case .notStarted, .finished:
            .free
        case .working:
            .atWork
        }
    }
}


// MARK: - Previews

#Preview {
    VStack {
        MeterHireStatusView(reading: .working(amountEarned: 1, progress: 0.1))
        MeterHireStatusView(reading: .working(amountEarned: 3, progress: 0.3))
        MeterHireStatusView(reading: .working(amountEarned: 6, progress: 0.6))
        MeterHireStatusView(reading: .working(amountEarned: 9, progress: 0.9))
        MeterHireStatusView(reading: .working(amountEarned: 9, progress: 0.9), showLiveStatusImage: true)
        MeterHireStatusView(reading: .notStarted)
        MeterHireStatusView(reading: .finished(amountEarned: 10))
    }
    .background(Color.darkGrey1)
}
