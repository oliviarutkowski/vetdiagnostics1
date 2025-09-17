import SwiftUI

struct ResourceListView: View {
    let resources: [Resource]

    var body: some View {
        List {
            Section("Protocols") {
                ForEach(resources) { resource in
                    NavigationLink(destination: ResourceDetailView(resource: resource)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(resource.title)
                                .font(AppTypography.headline)
                            Text(resource.summary)
                                .font(AppTypography.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text("Resource: \(resource.title)"))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(AppColor.background)
    }
}

struct ResourceDetailView: View {
    let resource: Resource

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(resource.title)
                    .font(AppTypography.title)
                    .fontWeight(.bold)
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(resource.sections) { section in
                        AppCard(title: section.title) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(section.pointItems) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(AppColor.accent)
                                            .font(.caption)
                                        Text(point.text)
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
            .padding(20)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Guideline")
    }
}

struct Resource: Identifiable {
    struct Section: Identifiable {
        let id = UUID()
        let title: String
        let points: [String]

        struct Point: Identifiable {
            let id: Int
            let text: String
        }

        var pointItems: [Point] {
            points.enumerated().map { Point(id: $0.offset, text: $0.element) }
        }
    }

    let id = UUID()
    let title: String
    let summary: String
    let sections: [Section]

    static let mock: [Resource] = [
        Resource(
            title: "Post-operative respiratory care",
            summary: "Checklist for supporting patients after airway procedures.",
            sections: [
                Section(title: "Immediate care", points: [
                    "Monitor respiratory effort every 15 minutes for the first hour.",
                    "Provide humidified oxygen if saturation drops below 94%."
                ]),
                Section(title: "At-home guidance", points: [
                    "Share step-down steroid tapering schedule with caregivers.",
                    "Provide emergency triggers that should prompt clinic contact."
                ])
            ]
        ),
        Resource(
            title: "GI distress stabilization",
            summary: "Evidence-based interventions for acute gastrointestinal flare-ups.",
            sections: [
                Section(title: "Intake considerations", points: [
                    "Recommend bland diet transition over 12 hours.",
                    "Encourage small, frequent hydration intervals."
                ]),
                Section(title: "Follow-up", points: [
                    "Schedule recheck if symptoms persist beyond 24 hours.",
                    "Collect stool sample for lab analysis if bleeding occurs."
                ])
            ]
        )
    ]
}
