import SwiftUI

struct ProfileView: View {
    @State private var pets: [PetProfile] = PetProfile.mock
    @State private var showAddSheet = false
    @State private var editingPet: PetProfile? = nil
    @State private var showResources = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                petRosterSection
                accountActions
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add pet", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                PetEditorView(pet: .constant(PetProfile.empty)) { newPet in
                    pets.append(newPet)
                    showAddSheet = false
                }
                .navigationTitle("Add pet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showAddSheet = false
                        }
                    }
                }
            }
        }
        .sheet(item: $editingPet) { pet in
            NavigationStack {
                PetEditorView(pet: .constant(pet)) { updatedPet in
                    if let index = pets.firstIndex(where: { $0.id == updatedPet.id }) {
                        pets[index] = updatedPet
                    }
                    editingPet = nil
                }
                .navigationTitle("Edit pet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            editingPet = nil
                        }
                    }
                }
            }
        }
    }

    private var petRosterSection: some View {
        AppCard(title: "My pets", subtitle: "Tap a profile to view or edit details.") {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 12) {
                    ForEach(pets) { pet in
                        Button {
                            editingPet = pet
                        } label: {
                            PetRow(pet: pet)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppColor.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppColor.separator.opacity(0.2))
                                )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    pets.removeAll { $0.id == pet.id }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 260)
        }
    }

    private var accountActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account & resources")
                .font(AppTypography.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                NavigationLink {
                    SettingsView()
                } label: {
                    actionRow(title: "Account settings", systemImage: "gear")
                }
                .buttonStyle(.plain)

                Button {
                    showResources = true
                } label: {
                    actionRow(title: "Care resources", systemImage: "book")
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showResources) {
                    NavigationStack {
                        ResourceListView(resources: Resource.mock)
                            .navigationTitle("Care resources")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showResources = false
                                    }
                                }
                            }
                    }
                }
            }
        }
    }

    private func actionRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .foregroundColor(AppColor.accent)
            Text(title)
                .font(AppTypography.body)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColor.separator.opacity(0.2))
        )
    }
}

struct PetRow: View {
    let pet: PetProfile

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColor.primaryGradient)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(pet.name.prefix(1)))
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(AppTypography.headline)
                Text("\(pet.species) · \(pet.age) yrs")
                    .font(AppTypography.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pet.name), \(pet.species), \(pet.age) years old")
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var shareAnalytics = false

    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Care alerts")
                }
                Toggle(isOn: $shareAnalytics) {
                    Text("Share anonymized analytics")
                }
            }

            Section(header: Text("About")) {
                Text("VetDiagnostics v1.0")
                Text("Support: support@vetdiagnostics.example")
            }
        }
    }
}

struct PetEditorView: View {
    @State private var draft: PetProfile
    let onSave: (PetProfile) -> Void

    init(pet: Binding<PetProfile>, onSave: @escaping (PetProfile) -> Void) {
        _draft = State(initialValue: pet.wrappedValue)
        self.onSave = onSave
    }

    @State private var weight: String = ""

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $draft.name)
                TextField("Species", text: $draft.species)
                Stepper(value: $draft.age, in: 0...30) {
                    Text("Age: \(draft.age) years")
                }
            }

            Section(header: Text("Vitals")) {
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Allergies", text: $draft.allergies)
            }

            Section(header: Text("Notes")) {
                TextEditor(text: Binding(
                    get: { draft.notes ?? "" },
                    set: { draft.notes = $0 }
                ))
                .frame(minHeight: 120)
            }
        }
        .onAppear {
            weight = draft.weight ?? ""
        }
        .onChange(of: weight) { newValue in
            draft.weight = newValue
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(draft)
                }
                .disabled(draft.name.isEmpty || draft.species.isEmpty)
            }
        }
    }
}

struct PetProfile: Identifiable, Equatable {
    let id: UUID
    var name: String
    var species: String
    var age: Int
    var weight: String?
    var allergies: String
    var notes: String?

    static var empty: PetProfile { PetProfile(id: UUID(), name: "", species: "", age: 0, weight: nil, allergies: "", notes: nil) }

    static let mock: [PetProfile] = [
        PetProfile(id: UUID(), name: "Luna", species: "Canine", age: 4, weight: "18", allergies: "Seasonal pollen", notes: "Responds well to inhaler therapy."),
        PetProfile(id: UUID(), name: "Atlas", species: "Feline", age: 7, weight: "6", allergies: "Chicken", notes: "Prefers pill pockets for medication."),
        PetProfile(id: UUID(), name: "Nova", species: "Canine", age: 2, weight: "22", allergies: "None", notes: "High energy, monitor post-op activity.")
    ]
}
