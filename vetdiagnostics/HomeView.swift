import SwiftUI

struct HomeView: View {
    private let featuredTips: [CareTip] = CareTip.mock
    private let recentAnalyses: [DiagnosisSummary] = DiagnosisSummary.mock

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroHeader
                quickActions
                insightsSection
                resourceSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .padding(.top, 12)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Welcome")
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Powered Care")
                .font(AppTypography.largeTitle)
                .fontWeight(.bold)
            Text("Run quick diagnostics, review insights, and keep pets healthy with real-time recommendations.")
                .font(AppTypography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColor.primaryGradient)
        )
        .overlay(alignment: .topTrailing) {
            StatusBadge(text: "New Insights", style: .info)
                .padding(16)
        }
        .foregroundColor(.white)
        .shadow(color: AppColor.accent.opacity(0.25), radius: 24, x: 0, y: 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI-powered care overview")
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick actions")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                NavigationLink {
                    AIDiagnosticView()
                } label: {
                    AppCard(title: "Start new diagnostic", subtitle: "Launch AI triage in under two minutes") {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Realtime vitals", systemImage: "waveform.path.ecg")
                                    .font(AppTypography.footnote)
                                    .foregroundColor(.secondary)
                                Label("Symptom comparison", systemImage: "list.bullet.rectangle")
                                    .font(AppTypography.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .buttonStyle(.plain)

                NavigationLink {
                    ResourceListView(resources: Resource.mock)
                } label: {
                    AppCard(title: "Clinical resources", subtitle: "Access evidence-based protocols") {
                        HStack {
                            StatusBadge(text: "Updated")
                            Spacer()
                            Image(systemName: "book.pages.fill")
                                .imageScale(.large)
                                .foregroundColor(AppColor.accent)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Latest analyses")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                ForEach(recentAnalyses) { summary in
                    NavigationLink {
                        DiagnosisDetailView(summary: summary)
                    } label: {
                        AppCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(summary.petName)
                                        .font(AppTypography.headline)
                                    Spacer()
                                    StatusBadge(text: summary.status.rawValue, style: summary.status.badgeStyle)
                                }
                                Text(summary.brief)
                                    .font(AppTypography.body)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Label(summary.timestamp, systemImage: "clock")
                                        .font(AppTypography.footnote)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var resourceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Care tips")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredTips) { tip in
                        VStack(alignment: .leading, spacing: 12) {
                            StatusBadge(text: tip.category, style: .info)
                            Text(tip.title)
                                .font(AppTypography.headline)
                                .foregroundColor(.primary)
                            Text(tip.description)
                                .font(AppTypography.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(20)
                        .frame(width: 260, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(AppColor.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(AppColor.separator.opacity(0.3))
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text("Care tip: \(tip.title)"))
                    }
                }
                .padding(.trailing, 20)
            }
        }
    }
}

struct CareTip: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let description: String

    static let mock: [CareTip] = [
        CareTip(category: "Hydration", title: "Monitor fluid intake", description: "Encourage regular hydration post-treatment to support renal function and avoid dehydration."),
        CareTip(category: "Mobility", title: "Gradual exercise", description: "Plan two short leash walks with light stretching to rebuild muscle without overexertion."),
        CareTip(category: "Nutrition", title: "High-protein snacks", description: "Offer small, protein-rich snacks spaced throughout the day to maintain energy between meals.")
    ]
}

struct DiagnosisSummary: Identifiable {
    enum Status: String {
        case stable = "Stable"
        case monitor = "Monitor"
        case urgent = "Urgent"

        var badgeStyle: StatusBadge.Style {
            switch self {
            case .stable:
                return .success
            case .monitor:
                return .warning
            case .urgent:
                return .warning
            }
        }
    }

    let id = UUID()
    let petName: String
    let brief: String
    let timestamp: String
    let status: Status
    let notes: [String]

    struct NoteItem: Identifiable {
        let id: Int
        let text: String
    }

    var noteItems: [NoteItem] {
        notes.enumerated().map { NoteItem(id: $0.offset, text: $0.element) }
    }

    static let mock: [DiagnosisSummary] = [
        DiagnosisSummary(
            petName: "Luna",
            brief: "Respiratory rate normalized after bronchodilator therapy.",
            timestamp: "20 min ago",
            status: .stable,
            notes: ["Continue monitoring at-home inhaler usage", "Schedule follow-up in 48 hours"]
        ),
        DiagnosisSummary(
            petName: "Atlas",
            brief: "Mild GI distress detected from symptom clustering.",
            timestamp: "1 hr ago",
            status: .monitor,
            notes: ["Recommend bland diet for 24 hours", "Flag recurrence for deeper scan"]
        ),
        DiagnosisSummary(
            petName: "Nova",
            brief: "Elevated temperature trending upward — watch closely.",
            timestamp: "Yesterday",
            status: .urgent,
            notes: ["Re-run vitals in clinic", "Consider anti-inflammatory protocol"]
        )
    ]
}
