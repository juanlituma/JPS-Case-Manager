//
//  BackgroundTaskManager.swift
//  JPSCaseApp
//
//  Registers and handles BGAppRefreshTask so the app can poll for resolved
//  cases even while it is suspended in the background.
//
//  ──────────────────────────────────────────────────────────────────────────
//  XCODE SETUP REQUIRED (one-time, in the Xcode GUI):
//  1. Select the JPSCaseApp target → "Signing & Capabilities" tab.
//  2. Click "+" → add "Background Modes" capability.
//  3. Tick "Background fetch".
//  ──────────────────────────────────────────────────────────────────────────
//
//  SIMULATOR TESTING:
//  Background tasks never fire automatically on the simulator.
//  To trigger one manually while the app is paused in Xcode:
//  1. Run the app, then press Home (Shift+Cmd+H).
//  2. In the Xcode console, paste and run:
//     e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.jps.caseapp.refresh"]
//  3. Resume (Ctrl+Cmd+Y) — the handler will execute.
//

import Foundation
import BackgroundTasks

final class BackgroundTaskManager {

    static let shared = BackgroundTaskManager()
    private init() {}

    // Must match Info.plist BGTaskSchedulerPermittedIdentifiers entry.
    let taskIdentifier = "com.jps.caseapp.refresh"

    // UserDefaults keys shared with AuthViewModel / CaseViewModel.
    private let tokenKey          = "jps_access_token"
    private let userIdKey         = "jps_user_id"
    /// Persists [caseId: statusRawValue] so background checks survive app restarts.
    private let statusSnapshotKey = "jps_case_status_snapshot"

    // MARK: - Registration (call once at app launch, before first runloop tick)

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleRefresh(refreshTask)
        }
    }

    // MARK: - Scheduling (call every time the app enters the background)

    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        // Earliest begin date — iOS may delay beyond this, but not before it.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)   // 15 min
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[BackgroundTask] Schedule failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Handler

    private func handleRefresh(_ task: BGAppRefreshTask) {
        // Immediately schedule the next refresh so the chain continues.
        scheduleNextRefresh()

        // Read stored credentials — bail out if not logged in.
        guard
            let token  = UserDefaults.standard.string(forKey: tokenKey), !token.isEmpty,
            UserDefaults.standard.object(forKey: userIdKey) != nil
        else {
            task.setTaskCompleted(success: true)
            return
        }
        let userId = UserDefaults.standard.integer(forKey: userIdKey)

        // Kick off an async fetch; cancel it if iOS revokes our time slice.
        let fetchWork = Task {
            do {
                let result = try await NetworkManager.shared.fetchCases(
                    token: token,
                    userId: userId
                )

                let previous = loadStatusSnapshot()

                // Only notify if we have a prior snapshot to compare against.
                if !previous.isEmpty {
                    for c in result.cases {
                        if let prev = previous[c.id],
                           prev != .resolved,
                           c.status == .resolved {
                            NotificationManager.shared.notifyCaseResolved(
                                caseId: c.id,
                                title: c.title
                            )
                        }
                    }
                }

                saveStatusSnapshot(cases: result.cases)
                task.setTaskCompleted(success: true)
            } catch {
                print("[BackgroundTask] Fetch error: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            fetchWork.cancel()
        }
    }

    // MARK: - Status Snapshot  (UserDefaults-backed, shared with CaseViewModel)

    /// Persist the current status of every case so subsequent background (or
    /// foreground) fetches can detect resolved transitions.
    func saveStatusSnapshot(cases: [CaseOut]) {
        // Store as [String: String] because UserDefaults doesn't handle Int keys.
        let dict = Dictionary(uniqueKeysWithValues: cases.map {
            (String($0.id), $0.status.rawValue)
        })
        UserDefaults.standard.set(dict, forKey: statusSnapshotKey)
    }

    /// Load the persisted snapshot.  Returns an empty dict on first run.
    func loadStatusSnapshot() -> [Int: CaseStatus] {
        guard let raw = UserDefaults.standard.dictionary(forKey: statusSnapshotKey)
                        as? [String: String]
        else { return [:] }

        var result: [Int: CaseStatus] = [:]
        for (key, value) in raw {
            if let id = Int(key), let status = CaseStatus(rawValue: value) {
                result[id] = status
            }
        }
        return result
    }
}
