//
//  CaseDetailView.swift
//  JPSCaseApp
//
//  Full-screen detail view for a single case.
//  Presented via NavigationLink from CaseNotificationView.
//

import SwiftUI

struct CaseDetailView: View {

    let caseItem: CaseOut

    // MARK: - Helpers

    private var statusColor: Color {
        switch caseItem.status {
        case .open:       return .blue
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }

    private var statusIcon: String {
        switch caseItem.status {
        case .open:       return "folder.badge.plus"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .resolved:   return "checkmark.seal.fill"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── Hero header ───────────────────────────────────────────
                HeroHeader(
                    caseId: caseItem.id,
                    title: caseItem.title,
                    status: caseItem.status,
                    statusColor: statusColor,
                    statusIcon: statusIcon
                )

                // ── Description ───────────────────────────────────────────
                if let desc = caseItem.description, !desc.isEmpty {
                    DetailSection(title: "Description", icon: "doc.text") {
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }

                // ── Solution ──────────────────────────────────────────────
                if let sol = caseItem.solution, !sol.isEmpty {
                    DetailSection(title: "Solution", icon: "checkmark.seal.fill", iconColor: .green) {
                        Text(sol)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.08))
                            .cornerRadius(10)
                    }
                }

                // ── Case Info ─────────────────────────────────────────────
                DetailSection(title: "Case Info", icon: "info.circle") {
                    VStack(spacing: 12) {
                        if let provider = caseItem.deliveryProvider {
                            InfoRow(
                                icon: "bicycle",
                                iconColor: .blue,
                                label: "Delivery Provider",
                                value: provider.displayName
                            )
                        }
                        if let complaint = caseItem.complaintType {
                            InfoRow(
                                icon: "exclamationmark.bubble",
                                iconColor: .orange,
                                label: "Complaint Type",
                                value: complaint.displayName
                            )
                        }
                        InfoRow(
                            icon: "person.fill",
                            iconColor: caseItem.assignedToName != nil ? .purple : .secondary,
                            label: "Assigned To",
                            value: caseItem.assignedToName ?? "Unassigned"
                        )
                        InfoRow(
                            icon: "person.badge.plus",
                            iconColor: caseItem.createdByName != nil ? .teal : .secondary,
                            label: "Created By",
                            value: caseItem.createdByName ?? "Unknown"
                        )
                    }
                }

                // ── Timeline ──────────────────────────────────────────────
                DetailSection(title: "Timeline", icon: "clock") {
                    VStack(spacing: 12) {
                        InfoRow(
                            icon: "plus.circle",
                            iconColor: .blue,
                            label: "Created",
                            value: formattedFull(caseItem.createdAt)
                        )
                        InfoRow(
                            icon: "arrow.clockwise.circle",
                            iconColor: .orange,
                            label: "Last Updated",
                            value: formattedFull(caseItem.updatedAt)
                        )
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Case #\(caseItem.id)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Date Formatting

    private func formattedFull(_ iso: String) -> String {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: iso) {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            fmt.timeStyle = .short
            return fmt.string(from: date)
        }
        return iso
    }
}

// MARK: - Hero Header

private struct HeroHeader: View {
    let caseId: Int
    let title: String
    let status: CaseStatus
    let statusColor: Color
    let statusIcon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Status pill + Case ID row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                    Text(status.displayName)
                        .font(.caption).fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.15))
                .foregroundColor(statusColor)
                .clipShape(Capsule())

                Spacer()

                Text("Case #\(caseId)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Detail Section

private struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    var iconColor: Color = Color(hex: "1A3A5C")
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Open Case") {
    NavigationView {
        CaseDetailView(caseItem: CaseOut(
            id: 1,
            title: "Theft at Central Mall",
            description: "Suspect stole electronics worth $2,000 from the Apple Store. Security footage available.",
            solution: "ABC",
            deliveryProvider: nil,
            complaintType: nil,
            status: .open,
            createdById: 3,
            createdByName: nil,
            assignedToId: nil,
            assignedToName: nil,
            createdAt: "2024-01-10T08:00:00.000Z",
            updatedAt: "2024-01-10T08:00:00.000Z"
        ))
    }
}

#Preview("Resolved Case") {
    NavigationView {
        CaseDetailView(caseItem: CaseOut(
            id: 2,
            title: "Missing Food Order — DoorDash",
            description: "Customer did not receive their order from Burger King. Order #DD-99821.",
            solution: "Suspect identified via CCTV footage at the delivery hub. Warrant issued and customer refunded.",
            deliveryProvider: .doorDash,
            complaintType: .notReceiveFood,
            status: .resolved,
            createdById: 1,
            createdByName: "Officer Smith",
            assignedToId: 2,
            assignedToName: "Detective Johnson",
            createdAt: "2024-01-09T14:30:00.000Z",
            updatedAt: "2024-01-09T15:45:00.000Z"
        ))
    }
}
