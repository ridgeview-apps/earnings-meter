import Models
import PresentationViews
import SwiftUI

struct CircularHireStatusGauge: View {
    
    let reading: MeterReading
    let settings: MeterSettings
    
    var body: some View {
        Gauge(value: reading.progress) {
            MeterHireStatusView(reading: reading,
                                showStatusText: false,
                                showEmoji: settings.emojisEnabled)
            .font(.footnote)
        } currentValueLabel: {
            Text(reading.hireStatus.localizedStringResource)
                .textCase(.uppercase)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
        }
        .gaugeStyle(.accessoryCircular)
    }
}
