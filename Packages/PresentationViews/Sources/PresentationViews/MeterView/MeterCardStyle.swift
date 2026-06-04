import SwiftUI

enum MeterPresentationState: Equatable {
    case inactive
    case active
    case completed

    var headerColor: Color {
        switch self {
        case .inactive:
            .white.opacity(0.72)
        case .active:
            .white
        case .completed:
            .white.opacity(0.88)
        }
    }
}

private struct MeterCardStyle: ViewModifier {

    let presentationState: MeterPresentationState

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(
                        Color.darkGrey1
                            .shadow(.inner(color: .black.opacity(innerShadowOpacity), radius: 6, x: 0, y: 4))
                    )
            }
            .overlay {
                shape
                    .strokeBorder(borderGradient, lineWidth: borderWidth)
            }
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 3)
            .animation(.snappy, value: presentationState)
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(topBorderOpacity), location: 0),
                .init(color: .white.opacity(midBorderOpacity), location: 0.55),
                .init(color: .white.opacity(bottomBorderOpacity), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var topBorderOpacity: Double {
        switch presentationState {
        case .inactive:
            0.55
        case .active:
            0.85
        case .completed:
            0.72
        }
    }

    private var midBorderOpacity: Double {
        switch presentationState {
        case .inactive:
            0.38
        case .active:
            0.65
        case .completed:
            0.5
        }
    }

    private var bottomBorderOpacity: Double {
        switch presentationState {
        case .inactive:
            0.28
        case .active:
            0.45
        case .completed:
            0.36
        }
    }

    private var borderWidth: CGFloat {
        presentationState == .active ? 2 : 1.5
    }

    private var innerShadowOpacity: Double {
        presentationState == .active ? 0.55 : 0.42
    }

    private var shadowColor: Color {
        switch presentationState {
        case .inactive:
            .black.opacity(0.16)
        case .active:
            .black.opacity(0.22)
        case .completed:
            Color.redOne.opacity(0.12)
        }
    }

    private var shadowRadius: CGFloat {
        presentationState == .active ? 6 : 4
    }
}

extension View {
    func meterCardStyle(_ presentationState: MeterPresentationState) -> some View {
        modifier(MeterCardStyle(presentationState: presentationState))
    }
}
