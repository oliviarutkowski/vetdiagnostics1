import SwiftUI
import MessageUI
import UIKit

struct MockResultOverlay: View {
    @Binding var showOverlay: Bool
    @Binding var showMailComposer: Bool
    private let result = MockResult.sample

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showOverlay = false
                    }
                }
                .accessibilityLabel("Dismiss results")

            VStack(spacing: 20) {
                Capsule()
                    .frame(width: 60, height: 6)
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Preliminary results")
                            .font(AppTypography.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showOverlay = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityLabel("Close results")
                    }

                    AppCard(title: result.primaryCondition, subtitle: "Confidence \(Int(result.confidence * 100))%") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(result.description)
                                .font(AppTypography.body)
                                .foregroundColor(.primary)
                            NavigationLink {
                                DiagnosisDetailView(summary: result.summary)
                            } label: {
                                Label("View diagnostic timeline", systemImage: "chevron.right")
                                    .foregroundColor(AppColor.accent)
                                    .font(AppTypography.subheadline)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    AppCard(title: "Next steps", subtitle: "Suggested interventions") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(result.stepItems) { step in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(AppColor.accent)
                                    Text(step.text)
                                        .font(AppTypography.body)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppColor.background)
                )
                .frame(maxWidth: 640)
                .accessibilityElement(children: .contain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)

            Button {
                showMailComposer = true
            } label: {
                Label("Report issue", systemImage: "envelope.badge")
                    .font(AppTypography.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppColor.primaryGradient)
                    )
                    .foregroundColor(.white)
                    .shadow(color: AppColor.accent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 28)
            .padding(.bottom, 44)
            .accessibilityLabel("Report issue via email")
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    let subject: String
    let body: String

    func makeUIViewController(context: Context) -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Mail unavailable", message: "Configure a mail account on this device to send feedback.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                dismiss()
                isPresented = false
            })
            return alert
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView

        init(parent: MailComposerView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                parent.isPresented = false
            }
        }
    }
}

private struct MockResult {
    let primaryCondition: String
    let confidence: Double
    let description: String
    let nextSteps: [String]
    let summary: DiagnosisSummary

    struct Step: Identifiable {
        let id: Int
        let text: String
    }

    var stepItems: [Step] {
        nextSteps.enumerated().map { Step(id: $0.offset, text: $0.element) }
    }

    static let sample = MockResult(
        primaryCondition: "Upper respiratory inflammation",
        confidence: 0.78,
        description: "AI detected consistent bronchial inflammation patterns similar to previous cases with positive steroid response.",
        nextSteps: [
            "Schedule in-clinic follow-up within 24 hours.",
            "Share inhaler usage plan with caregiver via the app.",
            "Flag case for manual specialist review."
        ],
        summary: DiagnosisSummary.mock.first ?? DiagnosisSummary(
            petName: "Luna",
            brief: "Respiratory rate normalized after bronchodilator therapy.",
            timestamp: "20 min ago",
            status: .stable,
            notes: ["Continue monitoring at-home inhaler usage", "Schedule follow-up in 48 hours"]
        )
    )
}
