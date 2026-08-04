//
//  ContentView.swift
//  JPSCaseApp
//
//  Root view — switches between LoginView and the main tab bar.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}


// MARK: - Previews

#Preview("Login Screen") {
    ContentView()
        .environmentObject(AuthViewModel())
}

#Preview("Main Tabs") {
    let auth = AuthViewModel()
    auth.isLoggedIn = true
    auth.currentUser = UserOut(
        id: 1,
        username: "officer_demo",
        email: "demo@jps.gov",
        fullName: "Demo Officer",
        isActive: true,
        createdAt: "2024-01-01T00:00:00"
    )
    return ContentView()
        .environmentObject(auth)
}

// MARK: - Main Tab Bar (shown after login)

struct MainTabView: View {

    @EnvironmentObject var auth: AuthViewModel

    // Shared CaseViewModel — created once after login so polling persists across tabs
    @StateObject private var caseVM: CaseViewModel

    init() {
        // Both token and userId are persisted at login time by AuthViewModel
        let token  = UserDefaults.standard.string(forKey: "jps_access_token") ?? ""
        let userId = UserDefaults.standard.integer(forKey: "jps_user_id")
        _caseVM = StateObject(wrappedValue: CaseViewModel(token: token, userId: userId))
    }

    var body: some View {
        TabView {
            // ── Create Case ───────────────────────────────────────────────
            CreateCaseView()
                .tabItem {
                    Label("New Case", systemImage: "plus.circle.fill")
                }

            // ── Case Notifications ────────────────────────────────────────
            CaseNotificationView()
                .tabItem {
                    Label("Cases", systemImage: "bell.fill")
                }
                .badge(caseVM.newCaseCount > 0 ? "\(caseVM.newCaseCount)" : nil)

            // ── Profile / Logout ──────────────────────────────────────────
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .environmentObject(caseVM)
        .onAppear { caseVM.startPolling() }
        .onDisappear { caseVM.stopPolling() }
    }
}

// MARK: - Profile / Logout View

private struct ProfileView: View {

    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationView {
            List {
                if let user = auth.currentUser {
                    Section("Account") {
                        LabeledContent("Username", value: user.username)
                        LabeledContent("Email",    value: user.email)
                        if let name = user.fullName, !name.isEmpty {
                            LabeledContent("Full Name", value: name)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
