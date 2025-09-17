import SwiftUI

struct DiagnosisDetailView: View {
    let summary: DiagnosisSummary
    @State private var showResourceSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                metrics
                recommendations
            }
            .padding(20)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(summary.petName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showResourceSheet.toggle()
                } label: {
                    Label("Resources", systemImage: "doc.text.magnifyingglass")
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel("View related resources")
            }
        }
        .sheet(isPresented: $showResourceSheet) {
            NavigationStack {
                ResourceListView(resources: Resource.mock)
                    .navigationTitle("Resources")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showResourceSheet = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(summary.brief)
                    .font(AppTypography.title2)
                    .fontWeight(.semibold)
                Spacer()
                StatusBadge(text: summary.status.rawValue, style: summary.status.badgeStyle)
            }
            Label(summary.timestamp, systemImage: "clock")
                .font(AppTypography.footnote)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.primaryGradient)
        )
        .foregroundColor(.white)
        .shadow(color: AppColor.accent.opacity(0.2), radius: 22, x: 0, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Summary: \(summary.brief)"))
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key signals")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                ForEach(MockSignal.all) { signal in
                    AppCard(title: signal.title, subtitle: signal.subtitle) {
                        HStack(alignment: .center, spacing: 12) {
                            Gauge(value: signal.percentage)
                                .frame(width: 70, height: 70)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(signal.description)
                                    .font(AppTypography.body)
                                    .foregroundColor(.secondary)
                                StatusBadge(text: signal.status, style: signal.badgeStyle)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Care recommendations")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(summary.noteItems) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColor.accent)
                            Text(note.text)
                                .font(AppTypography.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

private struct Gauge: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(AppColor.accent.opacity(0.15), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            Circle()
                .trim(from: 0, to: value)
                .stroke(AppColor.primaryGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(value * 100))%")
                .font(AppTypography.subheadline)
                .fontWeight(.semibold)
        }
        .padding(8)
        .accessibilityLabel(Text("Confidence \(Int(value * 100)) percent"))
    }
}

private struct MockSignal: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let percentage: Double
    let status: String
    let badgeStyle: StatusBadge.Style

    static let all: [MockSignal] = [
        MockSignal(title: "Respiration", subtitle: "AI confidence", description: "Breathing stabilized within expected range.", percentage: 0.82, status: "Stable", badgeStyle: .success),
        MockSignal(title: "Temperature", subtitle: "Trend deviation", description: "Slight elevation persists — reassess in clinic.", percentage: 0.64, status: "Monitor", badgeStyle: .warning),
        MockSignal(title: "Activity", subtitle: "Movement index", description: "Mobility readings suggest mild stiffness after rest.", percentage: 0.48, status: "Watch", badgeStyle: .info)
    ]
}
