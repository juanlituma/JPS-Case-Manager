//
//  NotificationManager.swift
//  JPSCaseApp
//
//  Manages local push notifications for case status changes.
//  Uses UNUserNotificationCenter — no APNs server or Apple Developer
//  account required.  Notifications fire even when the app is in the
//  background (as long as the poll timer is running).
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private override init() {
        super.init()
        // Set delegate so foreground notifications are also shown as banners.
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission

    // Ask for permission when app launch for the first time
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error {
                print("[Notifications] Permission error: \(error.localizedDescription)")
            } else {
                print("[Notifications] Permission granted: \(granted)")
            }
        }
    }

    // MARK: -  Notification

    // Triggers an immediate notification telling the user that a
    // case has been resolved.
    func notifyCaseResolved(caseId: Int, title caseTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Case Resolved ✓"
        content.body  = "Case #\(caseId) \"\(caseTitle)\" has been resolved."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Use id to prevent duplication.
        let identifier = "case_resolved_\(caseId)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Remove any pending duplicate before adding the new one.
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[Notifications] Failed to schedule: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Show notification banners even while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
