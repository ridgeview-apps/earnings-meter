import Models
import PresentationViews
import SwiftUI

struct CircularHireStatusGauge: View {

    let reading: MeterReading

    var body: some View {
        Gauge(value: reading.progress) {
            MeterHireStatusView(
                reading: reading,
                showStatusText: false
            )
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
