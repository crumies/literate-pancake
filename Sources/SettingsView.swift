import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var ble: DunenBLEManager

    @State private var devTapCount = 0
    @State private var showDevUnlocked = false
    @State private var showDeveloperOptions = false
    @State private var showTuningWarning = false
    @State private var requestedTuningState = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Settings").font(.largeTitle.weight(.heavy))
                        Text("APTUM Dashboard").font(.caption).foregroundStyle(.cyan)
                    }
                    Spacer()
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Display").font(.headline)

                        Picker("Appearance", selection: Binding(get: { settings.appearance }, set: { settings.appearance = $0 })) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Speed", selection: Binding(get: { settings.speedUnit }, set: { settings.speedUnit = $0 })) {
                            ForEach(SpeedUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                GlassCard {
                    VStack(spacing: 16) {
                        Toggle("Startup animation", isOn: $settings.startupAnimation).tint(.cyan)
                        Toggle("Show raw packet logger", isOn: $settings.showRawPackets).tint(.cyan)

                        Toggle("Tuning unlocked", isOn: Binding(
                            get: { settings.expertTuningUnlocked },
                            set: { newValue in
                                requestedTuningState = newValue
                                if newValue {
                                    showTuningWarning = true
                                } else {
                                    settings.expertTuningUnlocked = false
                                }
                            }
                        ))
                        .tint(.orange)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Connection").font(.headline)
                        Text(ble.connectionStatus).font(.caption).foregroundStyle(.secondary)

                        HStack {
                            Button(ble.isScanning ? "Scanning..." : "Scan") { ble.startScan() }
                                .buttonStyle(.borderedProminent)
                                .tint(.cyan)
                                .disabled(ble.isScanning)

                            Button(ble.isDemoMode ? "Stop Demo" : "Demo Mode") {
                                ble.setDemoMode(!ble.isDemoMode)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                if settings.developerUnlocked {
                    Button("Developer Options") {
                        showDeveloperOptions = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }

                footer
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 112)
        }
        .alert("Developer menu unlocked", isPresented: $showDevUnlocked) {
            Button("OK") {}
        } message: {
            Text("Developer Options button has been added to Settings.")
        }
        .alert("Unlock tuning?", isPresented: $showTuningWarning) {
            Button("Cancel", role: .cancel) { settings.expertTuningUnlocked = false }
            Button("I Understand", role: .destructive) { settings.expertTuningUnlocked = requestedTuningState }
        } message: {
            Text("Changing controller parameters is your own responsibility. Read current settings and backup before writing.")
        }
        .sheet(isPresented: $showDeveloperOptions) {
            DeveloperOptionsView()
                .environmentObject(settings)
                .environmentObject(ble)
                .presentationDetents([.medium, .large])
        }
    }

    private var footer: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text("© 2026 APTUM – Always Progressing Toward Ultimate Mobility")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("Developed by crumies")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)
                    .onTapGesture {
                        devTapCount += 1
                        if devTapCount >= 5 {
                            settings.developerUnlocked = true
                            showDevUnlocked = true
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct DeveloperOptionsView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var ble: DunenBLEManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Update Frequency") {
                    Picker("Telemetry update", selection: Binding(get: { settings.updateInterval }, set: { newValue in
                        settings.updateInterval = newValue
                        ble.applyDeveloperUpdateInterval()
                    })) {
                        ForEach(UpdateInterval.allCases) { interval in
                            Text(interval.label).tag(interval)
                        }
                    }
                }

                Section("Bluetooth Info") {
                    row("Connected", ble.isConnected ? "Yes" : "No")
                    row("Demo", ble.isDemoMode ? "Yes" : "No")
                    row("Status", ble.connectionStatus)
                    row("Saved devices", "\(ble.savedDevices.count)")
                    row("Developer", ble.developerStatus)
                }

                Section("Remembered Devices") {
                    ForEach(ble.savedDevices) { device in
                        VStack(alignment: .leading) {
                            Text(device.name)
                            Text(device.id.uuidString).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Developer Options")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func row(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
