import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var ble: DunenBLEManager
    @EnvironmentObject var settings: AppSettings

    var speed: Double {
        settings.speedUnit == .kmh ? ble.telemetry.speedKmh : ble.telemetry.speedKmh * 0.621371
    }

    var odo: String {
        settings.speedUnit == .kmh ? String(format: "%.1f km", ble.telemetry.odometerKm) : String(format: "%.1f mi", ble.telemetry.odometerKm * 0.621371)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                SpeedometerView(speed: speed, unit: settings.speedUnit.rawValue, rpm: ble.telemetry.rpm)
                    .frame(height: 356)

                GlassCard {
                    HStack {
                        metric("Voltage", String(format: "%.1f V", ble.telemetry.voltage))
                        metric("Odometer", odo)
                    }
                }

                HStack(spacing: 12) {
                    graphCard("Speed", values: ble.history.speed, unit: settings.speedUnit.rawValue)
                    graphCard("RPM", values: ble.history.rpm, unit: "rpm")
                }

                HStack(spacing: 12) {
                    graphCard("Voltage", values: ble.history.voltage, unit: "V")
                    graphCard("Current", values: ble.history.current, unit: "calc")
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 112)
        }
    }

    private var header: some View {
        HStack {
            AptumLogoImage()
                .frame(width: 155, height: 52)
            Spacer()
            ConnectionPill()
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func graphCard(_ title: String, values: [Double], unit: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(unit).font(.caption2).foregroundStyle(.cyan)
                }
                MiniLineGraph(values: values)
                    .frame(height: 54)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SpeedometerView: View {
    let speed: Double
    let unit: String
    let rpm: Int

    var clamped: Double { min(max(speed, 0), 180) }

    var body: some View {
        GlassCard(glow: true) {
            ZStack {
                ForEach(0..<37) { i in
                    let angle = -135.0 + Double(i) * 270.0 / 36.0
                    Rectangle()
                        .fill(i % 3 == 0 ? .white.opacity(0.75) : .white.opacity(0.25))
                        .frame(width: i % 3 == 0 ? 3 : 1.4, height: i % 3 == 0 ? 22 : 12)
                        .offset(y: -135)
                        .rotationEffect(.degrees(angle))
                }

                Circle().stroke(.cyan.opacity(0.14), lineWidth: 22).frame(width: 260)
                Circle()
                    .trim(from: 0, to: clamped / 180 * 0.75)
                    .stroke(AngularGradient(colors: [.cyan, .blue, .cyan], center: .center), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .frame(width: 260)
                    .rotationEffect(.degrees(135))

                VStack(spacing: 2) {
                    Text("\(Int(speed.rounded()))").font(.system(size: 78, weight: .heavy, design: .rounded))
                    Text(unit).font(.caption.weight(.bold)).foregroundStyle(.secondary)
                }

                VStack(alignment: .trailing, spacing: 0) {
                    Text("RPM").font(.caption2.weight(.bold)).foregroundStyle(.cyan)
                    Text("\(rpm)").font(.title2.weight(.bold)).foregroundStyle(.cyan)
                }
                .offset(x: 122, y: 130)
            }
            .frame(maxWidth: .infinity, minHeight: 316)
        }
    }
}
