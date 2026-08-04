//
//  AuthViewModel.swift
//  JPSCaseApp
//
//  Manages login / register state and stores the JWT token.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserOut? = nil
    @Published var token: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Persists token and user ID across app restarts (use Keychain in production)
    private let tokenKey  = "jps_access_token"
    private let userIdKey = "jps_user_id"

    init() {
        // Restore saved token on launch
        if let saved = UserDefaults.standard.string(forKey: tokenKey), !saved.isEmpty {
            token = saved
            isLoggedIn = true
        }
    }

    // MARK: - Register

    func register(username: String, email: String, fullName: String, password: String) async {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await NetworkManager.shared.register(
                username: username,
                email: email,
                fullName: fullName.isEmpty ? nil : fullName,
                password: password
            )
            // Auto-login after register
            await login(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Login

    func login(username: String, password: String) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let tokenResponse = try await NetworkManager.shared.login(
                username: username,
                password: password
            )
            token = tokenResponse.accessToken
            currentUser = tokenResponse.user
            UserDefaults.standard.set(token, forKey: tokenKey)
            UserDefaults.standard.set(tokenResponse.user.id, forKey: userIdKey)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Logout

    func logout() {
        token = ""
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
