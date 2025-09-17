import SwiftUI

struct AIDiagnosticView: View {
    @State private var selectedStage = 0
    @State private var selectedPetIndex = 0
    @State private var symptomSeverity = 2
    @State private var symptomNotes = ""
    @State private var includeVitals = true
    @State private var showOverlay = false
    @State private var showAlert = false
    @State private var showMailComposer = false

    private let pets = ["Luna", "Atlas", "Nova"]
    private let stages = ["Intake", "Vitals", "Summary"]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    stageSelector
                    intakeSection
                    vitalsSection
                    summarySection
                }
                .padding(20)
            }
            .background(AppColor.background.ignoresSafeArea())

            if showOverlay {
                MockResultOverlay(showOverlay: $showOverlay, showMailComposer: $showMailComposer)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.isModal)
            }
        }
        .navigationTitle("AI Diagnostic")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAlert = true
                } label: {
                    Label("Safety", systemImage: "exclamationmark.shield")
                }
            }
        }
        .alert("AI safety", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Remember to confirm AI recommendations with clinical judgment before proceeding.")
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(isPresented: $showMailComposer, subject: "Report Diagnostic Issue", body: "I'd like to report a potential issue with the AI diagnostic result.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guided triage")
                .font(AppTypography.title)
                .fontWeight(.bold)
            Text("Capture the latest observations, adjust weightings, and let the AI surface probable conditions with confidence scores.")
                .font(AppTypography.body)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.primaryGradient)
        )
        .foregroundColor(.white)
        .shadow(color: AppColor.accent.opacity(0.2), radius: 22, x: 0, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Guided triage introduction"))
    }

    private var stageSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workflow stage")
                .font(AppTypography.headline)
            AppSegmentedControl(selection: $selectedStage, options: stages)
        }
    }

    private var intakeSection: some View {
        AppCard(title: "1. Intake details", subtitle: "Select the patient and capture present symptoms") {
            Picker("Pet", selection: $selectedPetIndex) {
                ForEach(petOptions) { option in
                    Text(option.name)
                        .tag(option.id)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Pet selection")

            Stepper(value: $symptomSeverity, in: 0...4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Symptom intensity")
                        .font(AppTypography.subheadline)
                    Text(SymptomSeverity(rawValue: symptomSeverity)?.description ?? "")
                        .font(AppTypography.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityLabel("Symptom intensity stepper")

            AppTextEditor(title: "Observation notes", text: $symptomNotes)
                .accessibilityHint("Describe symptoms in detail")
        }
    }

    private var vitalsSection: some View {
        AppCard(title: "2. Vitals weighting", subtitle: "Toggle sensor data to include in this run") {
            Toggle(isOn: $includeVitals) {
                Text("Include wearable vitals stream")
                    .font(AppTypography.body)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppColor.accent))
            .accessibilityLabel("Include wearable vitals stream")

            VStack(alignment: .leading, spacing: 12) {
                ForEach(MockVital.all) { vital in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vital.name)
                                .font(AppTypography.headline)
                            Text(vital.details)
                                .font(AppTypography.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        StatusBadge(text: vital.badge, style: vital.badgeStyle)
                    }
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3. Review & run")
                .font(AppTypography.headline)
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Selected pet", systemImage: "pawprint.fill")
                        Spacer()
                        Text(pets[selectedPetIndex])
                            .fontWeight(.semibold)
                    }
                    Divider()
                    HStack {
                        Label("Symptom intensity", systemImage: "thermometer")
                        Spacer()
                        Text(SymptomSeverity(rawValue: symptomSeverity)?.description ?? "")
                    }
                    Divider()
                    HStack {
                        Label("Vitals included", systemImage: includeVitals ? "waveform.path.ecg" : "slash.circle")
                        Spacer()
                        Text(includeVitals ? "Enabled" : "Disabled")
                            .foregroundColor(includeVitals ? AppColor.accent : .secondary)
                    }
                }
            }
            PrimaryGradientButton(title: "Run analysis", action: runAnalysis, icon: "sparkles")
        }
    }

    private func runAnalysis() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showOverlay = true
        }
    }
}

private enum SymptomSeverity: Int {
    case none = 0, mild, moderate, high, emergency

    var description: String {
        switch self {
        case .none: return "No notable issues"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .emergency: return "Emergency"
        }
    }
}

private struct MockVital: Identifiable {
    let id = UUID()
    let name: String
    let details: String
    let badge: String
    let badgeStyle: StatusBadge.Style

    static let all: [MockVital] = [
        MockVital(name: "Heart rate", details: "92 BPM · Slightly elevated", badge: "+6%", badgeStyle: .warning),
        MockVital(name: "Respiration", details: "26 RPM · Within target", badge: "Stable", badgeStyle: .success),
        MockVital(name: "Temperature", details: "102.1°F · Rising", badge: "Alert", badgeStyle: .warning)
    ]
}

private extension AIDiagnosticView {
    struct PetOption: Identifiable {
        let id: Int
        let name: String
    }

    var petOptions: [PetOption] {
        pets.enumerated().map { PetOption(id: $0.offset, name: $0.element) }
    }
}
