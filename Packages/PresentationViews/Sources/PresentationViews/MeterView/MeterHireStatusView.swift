import Models
import SwiftUI

public struct MeterHireStatusView: View {

    // MARK: - Data types

    public enum Status: Equatable {
        case free
        case atWork
    }


    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.appAnimationsEnabled) private var appAnimationsEnabled


    // MARK: - Properties

    public let status: Status
    public let progressValue: Double
    public let showStatusText: Bool

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 6) {
            if showStatusText {
                statusText
            }
            if status == .atWork {
                Image(systemName: statusSymbolName)
                    .imageScale(.small)
                    .foregroundStyle(statusSymbolPrimaryColor, statusSymbolSecondaryColor)
                    .symbolRenderingMode(.palette)
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(
                        .pulse,
                        options: .repeating,
                        isActive: appAnimationsEnabled
                    )
            }
        }
    }

    private var statusText: some View {
        Text(status.localizedStringResource)
            .instrumentLabel(.footnote)
            .foregroundColor(.white)
    }

    private var statusSymbolName: String {
        "briefcase.fill"
    }

    private var statusSymbolPrimaryColor: Color {
        .redOne
    }

    private var statusSymbolSecondaryColor: Color {
        .white.opacity(0.85)
    }
}


// MARK: - Convenience init

public extension MeterHireStatusView {

    init(
        reading: MeterReading,
        showStatusText: Bool = true
    ) {
        self.status = reading.hireStatus
        self.progressValue = reading.progress
        self.showStatusText = showStatusText
    }

}

// MARK: - Hire status localized text

public extension MeterHireStatusView.Status {

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .free: .meterHireStatusFree
        case .atWork: .meterHireStatusAtWork
        }
    }
}

public extension MeterReading {

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
        MeterHireStatusView(reading: .working(amountEarned: 6, progress: 0.6))
        MeterHireStatusView(reading: .working(amountEarned: 9, progress: 0.9))
        MeterHireStatusView(reading: .notStarted)
        MeterHireStatusView(reading: .finished(amountEarned: 10))
    }
    .background(Color.darkGrey1)
}
