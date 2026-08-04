//
//  CaseNotificationView.swift
//  JPSCaseApp
//
//  Live case list — polls the server every Config.pollInterval seconds
//  and shows a badge when new cases arrive.
//

import SwiftUI

struct CaseNotificationView: View {

    @EnvironmentObject var caseVM: CaseViewModel
    @State private var selectedStatus: CaseStatus = .open
    @State private var navigateToCase: CaseOut? = nil

    private var filteredCases: [CaseOut] {
        caseVM.cases.filter { $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Stats bar ─────────────────────────────────────────────
                StatsBar(total: caseVM.totalCases, resolvedCount: caseVM.resolvedCaseCount) {
                    if caseVM.recentlyResolvedCases.count == 1 {
                        navigateToCase = caseVM.recentlyResolvedCases.first
                    } else {
                        selectedStatus = .resolved
                    }
                    caseVM.clearResolvedCaseCount()
                }

                // ── Status filter ─────────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(CaseStatus.allCases, id: \.self) { status in
                            StatusChip(label: status.displayName, isSelected: selectedStatus == status) {
                                selectedStatus = status
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .background(Color(.secondarySystemBackground))

                Divider()

                // ── Case list ─────────────────────────────────────────────
                if caseVM.isLoading && caseVM.cases.isEmpty {
                    Spacer()
                    ProgressView("Loading cases…")
                    Spacer()
                } else if filteredCases.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No cases found")
                            .font(.headline).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(filteredCases) { item in
                        NavigationLink(destination: CaseDetailView(caseItem: item)) {
                            CaseRowView(caseItem: item)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        caseVM.fetchCases()
                    }
                }
            }
            .navigationTitle("Cases")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        caseVM.fetchCases()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(caseVM.isLoading ? 360 : 0))
                            .animation(
                                caseVM.isLoading
                                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                                    : .default,
                                value: caseVM.isLoading
                            )
                    }
                    .disabled(caseVM.isLoading)
                }
            }
            .navigationDestination(item: $navigateToCase) { caseItem in
                CaseDetailView(caseItem: caseItem)
            }
        }
        // .onAppear {
        //     caseVM.clearNewCaseCount()
        //     caseVM.clearResolvedCaseCount()
        // }
    }
}

// MARK: - Stats Bar

private struct StatsBar: View {
    let total: Int
    let resolvedCount: Int
    let onResolvedTap: () -> Void

    var body: some View {
        HStack {
            Label("\(total) total cases", systemImage: "folder.fill")
                .font(.subheadline).foregroundColor(.secondary)
            Spacer()
            if resolvedCount > 0 {
                Button(action: onResolvedTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("\(resolvedCount) resolved")
                    }
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Status Filter Chip

private struct StatusChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline).fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(hex: "1A3A5C") : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Case Row

private struct CaseRowView: View {
    let caseItem: CaseOut

    private var statusColor: Color {
        switch caseItem.status {
        case .open:       return .blue
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Case #\(caseItem.id)")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                // Status badge
                Text(caseItem.status.displayName)
                    .font(.caption2).fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }

            Text(caseItem.title)
                .font(.headline)
                .lineLimit(2)

            if let desc = caseItem.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if let sol = caseItem.solution, !sol.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(sol)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                .padding(8)
                .background(Color.green.opacity(0.08))
                .cornerRadius(8)
            }

            // Delivery provider & complaint type tags
            let hasTags = caseItem.deliveryProvider != nil || caseItem.complaintType != nil
            if hasTags {
                HStack(spacing: 6) {
                    if let provider = caseItem.deliveryProvider {
                        HStack(spacing: 4) {
                            Image(systemName: "bicycle")
                                .font(.caption2)
                            Text(provider.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.10))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    }
                    if let complaint = caseItem.complaintType {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.bubble")
                                .font(.caption2)
                            Text(complaint.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.10))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(formattedDate(caseItem.updatedAt))
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            return rel.localizedString(for: date, relativeTo: Date())
        }
        return iso
    }
}

// MARK: - Previews

#Preview("With Cases") {
    let vm: CaseViewModel = {
        let vm = CaseViewModel(token: "preview", userId: 0)
        vm.cases = [
            CaseOut(id: 1, title: "Theft at Central Mall", description: "Suspect stole electronics worth $2,000.", solution: nil, deliveryProvider: nil, complaintType: nil, status: .open, createdById: 1, createdByName: nil, assignedToId: nil, assignedToName: nil, createdAt: "2024-01-10T08:00:00Z", updatedAt: "2024-01-10T08:00:00Z"),
            CaseOut(id: 2, title: "Missing Food Order", description: "Customer did not receive their order.", solution: "Suspect identified via CCTV. Warrant issued.", deliveryProvider: .doorDash, complaintType: .notReceiveFood, status: .inProgress, createdById: 2, createdByName: nil, assignedToId: 1, assignedToName: nil, createdAt: "2024-01-09T14:30:00Z", updatedAt: "2024-01-09T15:00:00Z"),
            CaseOut(id: 3, title: "Wrong Order Delivered", description: nil, solution: "Refund issued to customer.", deliveryProvider: .uber, complaintType: .receivedWrongOrder, status: .resolved, createdById: 3, createdByName: nil, assignedToId: 2, assignedToName: nil, createdAt: "2024-01-08T22:00:00Z", updatedAt: "2024-01-09T09:00:00Z"),
            CaseOut(id: 4, title: "Missing Items in Bag", description: "Two items missing from the order.", solution: nil, deliveryProvider: .selfDelivery, complaintType: .missingItem, status: .open, createdById: 1, createdByName: nil, assignedToId: nil, assignedToName: nil, createdAt: "2024-01-07T11:00:00Z", updatedAt: "2024-01-07T16:00:00Z"),
        ]
        vm.totalCases = 4
        vm.resolvedCaseCount = 2
        return vm
    }()
    CaseNotificationView()
        .environmentObject(vm)
}

#Preview("Empty") {
    CaseNotificationView()
        .environmentObject(CaseViewModel(token: "preview", userId: 0))
}
