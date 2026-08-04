//
//  CaseViewModel.swift
//  JPSCaseApp
//
//  Manages the case list and polls the server for updates.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class CaseViewModel: ObservableObject {

    @Published var cases: [CaseOut] = []
    @Published var totalCases: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    // Notification badge — counts cases that arrived since last viewed
    @Published var newCaseCount: Int = 0
    private var lastKnownTotal: Int = 0

    // Badge for cases that transitioned to resolved since last viewed
    @Published var resolvedCaseCount: Int = 0
    @Published var recentlyResolvedCases: [CaseOut] = []

    /// Tracks the last-known status of every case by its ID.
    /// Used to detect transitions to .resolved and fire local notifications.
    private var previousStatuses: [Int: CaseStatus] = [:]

    private var token: String
    private var userId: Int
    private var pollTimer: Timer?

    init(token: String, userId: Int) {
        self.token  = token
        self.userId = userId
        // Restore snapshot saved by the last foreground poll or background task
        // so we never re-notify for cases that were already resolved.
        self.previousStatuses = BackgroundTaskManager.shared.loadStatusSnapshot()
    }

    // MARK: - Polling

    /// Start auto-polling at the interval defined in Config.
    func startPolling() {
        fetchCases()
        pollTimer = Timer.scheduledTimer(withTimeInterval: Config.pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fetchCases()
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    // MARK: - Fetch

    func fetchCases() {
        Task {
            isLoading = cases.isEmpty   // only show spinner on first load
            errorMessage = nil
            do {
                let result = try await NetworkManager.shared.fetchCases(token: token, userId: userId)
                let previousTotal = lastKnownTotal

                // ── Resolved-status notifications ────────────────────────────
                // Skip the very first fetch (previousStatuses is empty) to avoid
                // spamming notifications for cases that were already resolved
                // before the user opened the app.
                let isFirstLoad = previousStatuses.isEmpty

                if !isFirstLoad {
                    for c in result.cases {
                        let prevStatus = previousStatuses[c.id]
                        // Fire if: we knew the case before AND it just became resolved.
                        if let prev = prevStatus, prev != .resolved, c.status == .resolved {
                            NotificationManager.shared.notifyCaseResolved(
                                caseId: c.id,
                                title: c.title
                            )
                            resolvedCaseCount += 1
                            recentlyResolvedCases.append(c)
                        }
                    }
                }

                // Update the in-memory snapshot for the next poll cycle,
                // and persist it so background task fetches see the same state.
                previousStatuses = Dictionary(
                    uniqueKeysWithValues: result.cases.map { ($0.id, $0.status) }
                )
                BackgroundTaskManager.shared.saveStatusSnapshot(cases: result.cases)
                // ─────────────────────────────────────────────────────────────

                cases = result.cases
                totalCases = result.total

                // Detect new cases for the notification badge
                if previousTotal > 0 && result.total > previousTotal {
                    newCaseCount += result.total - previousTotal
                }
                lastKnownTotal = result.total
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    /// Clear the notification badges after the user views the list.
    func clearNewCaseCount() {
        newCaseCount = 0
    }

    func clearResolvedCaseCount() {
        resolvedCaseCount = 0
        recentlyResolvedCases = []
    }

    // MARK: - Create Case

    func createCase(
        title: String,
        description: String?,
        deliveryProvider: DeliveryProvider? = nil,
        complaintType: ComplaintType? = nil
    ) async -> Bool {
        guard !title.isEmpty else {
            errorMessage = "Case title cannot be empty."
            return false
        }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            let newCase = try await NetworkManager.shared.createCase(
                title: title,
                description: description,
                deliveryProvider: deliveryProvider,
                complaintType: complaintType,
                token: token
            )
            cases.insert(newCase, at: 0)
            totalCases += 1
            lastKnownTotal += 1
            successMessage = "Case #\(newCase.id) created successfully."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
