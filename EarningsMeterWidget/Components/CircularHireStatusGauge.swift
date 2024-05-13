import Models
import PresentationViews
import SwiftUI

struct CircularHireStatusGauge: View {
    
    let reading: MeterReading
    
    var body: some View {
        Gauge(value: reading.progress) {
            hireStatusView(showStatusText: false, showEmoji: true)
        } currentValueLabel: {
            hireStatusView(showStatusText: true, showEmoji: false)
        }
        .gaugeStyle(.accessoryCircular)
    }
    
    private func hireStatusView(showStatusText: Bool, showEmoji: Bool) -> some View {
        MeterHireStatusView(reading: reading,
                            showStatusText: showStatusText,
                            showEmoji: showEmoji)
        .font(.footnote)
    }
}
