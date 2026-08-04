//
//  JPSCaseApp.swift
//  JPSCaseApp
//
//  App entry point — inject AuthViewModel into the environment.
//

import SwiftUI
import BackgroundTasks

@main
struct JPSCaseApp: App {

    @StateObject private var auth = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Ask the user for notification permission on first launch.
        // iOS only shows the dialog once; subsequent calls are no-ops.
        NotificationManager.shared.requestPermission()

        // Register the background-refresh handler.
        // MUST be called before the app finishes launching (i.e. here in init).
        BackgroundTaskManager.shared.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
        // Every time the app moves to the background, schedule the next
        // background fetch so the notification chain stays alive.
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                BackgroundTaskManager.shared.scheduleNextRefresh()
            }
        }
    }
}
