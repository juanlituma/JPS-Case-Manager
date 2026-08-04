//
//  CreateCaseView.swift
//  JPSCaseApp
//
//  Form to submit a new case to the backend.
//

import SwiftUI

struct CreateCaseView: View {

    @EnvironmentObject var caseVM: CaseViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDelivery: DeliveryProvider? = nil
    @State private var selectedComplaint: ComplaintType? = nil
    @State private var showSuccess = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Header card ───────────────────────────────────────
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "1A3A5C"))
                                .frame(width: 52, height: 52)
                            Image(systemName: "folder.badge.plus")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("New Case")
                                .font(.title2).fontWeight(.bold)
                            Text("Fill in the details below")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    // ── Form fields ───────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Case Title", systemImage: "doc.text")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        TextField("Enter a brief title for the case", text: $title)
                            .focused($focused)
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description (optional)", systemImage: "text.alignleft")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Describe the case in detail…")
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                            }
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // ── Delivery Provider picker ──────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Delivery Provider", systemImage: "bicycle")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Picker("Delivery Provider", selection: $selectedDelivery) {
                            Text("— None —").tag(Optional<DeliveryProvider>.none)
                            ForEach(DeliveryProvider.allCases, id: \.self) { provider in
                                Text(provider.displayName).tag(Optional(provider))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // ── Complaint Type picker ─────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Complaint Type", systemImage: "exclamationmark.bubble")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Picker("Complaint Type", selection: $selectedComplaint) {
                            Text("— None —").tag(Optional<ComplaintType>.none)
                            ForEach(ComplaintType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(Optional(type))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // ── Error / success banners ───────────────────────────
                    if let err = caseVM.errorMessage {
                        ErrorBanner(message: err)
                    }

                    if showSuccess, let msg = caseVM.successMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(msg).font(.footnote)
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.85))
                        .cornerRadius(10)
                    }

                    // ── Submit button ─────────────────────────────────────
                    Button(action: submitCase) {
                        JPSButton(label: "Submit Case", isLoading: caseVM.isLoading)
                    }
                    .disabled(caseVM.isLoading || title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
                }
                .padding()
            }
            .navigationTitle("Create Case")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { focused = false }
        }
    }

    private func submitCase() {
        focused = false
        showSuccess = false
        Task {
            let ok = await caseVM.createCase(
                title: title.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
                deliveryProvider: selectedDelivery,
                complaintType: selectedComplaint
            )
            if ok {
                title = ""
                description = ""
                selectedDelivery = nil
                selectedComplaint = nil
                showSuccess = true
                // Auto-hide the success banner after 3 seconds
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                showSuccess = false
            }
        }
    }
}
