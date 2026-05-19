import SwiftUI

struct DiagnosticsView: View {
    @EnvironmentObject var ble: DunenBLEManager
    @EnvironmentObject var tuning: TuningStore
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Diagnostics").font(.largeTitle.weight(.heavy))
                        Text("Packets and parameter state").font(.caption).foregroundStyle(.cyan)
                    }
                    Spacer()
                    ConnectionPill()
                }

                GlassCard {
                    VStack(spacing: 12) {
                        row("Controller", ble.telemetry.controllerName)
                        row("Product", ble.telemetry.productModel)
                        row("Packets", "\(ble.telemetry.packetCount)")
                        row("Settings loaded", tuning.didLoadFromController ? "Yes" : "No")
                        row("Demo mode", ble.isDemoMode ? "On" : "Off")
                    }
                }

                if settings.showRawPackets {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Latest Raw Packet").font(.headline)
                            Text(ble.telemetry.rawHex.isEmpty ? "No packet yet" : ble.telemetry.rawHex)
                                .font(.system(size: 11, design: .monospaced))
                                .textSelection(.enabled)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.black.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            ForEach(ble.packetLog.prefix(12), id: \.self) { packet in
                                Text(packet)
                                    .font(.system(size: 10, design: .monospaced))
                                    .lineLimit(2)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 112)
        }
    }

    private func row(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
    }
}
