//
//  LoginView.swift
//  JPSCaseApp
//
//  Login and Register tabs with the JPS logo placeholder.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: Int = 0  // 0 = Login, 1 = Register

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "1A3A5C"), Color(hex: "52f2f0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    // ── JPS Logo Placeholder ──────────────────────────────
                    VStack(spacing: 12) {
                        ZStack {
//                            Circle()
//                                .fill(Color.white)
//                                .frame(width: 110, height: 110)
//                                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
//
//                            // Replace this with Image("JPSLogo") once you add your asset
//                            Text("JPS")
//                                .font(.system(size: 38, weight: .black, design: .rounded))
//                                .foregroundColor(Color(hex: "1A3A5C"))
                            Image("Logo")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                                .clipShape(Circle())
                        }

                        Text("Case Management")
                            .font(.title2).fontWeight(.semibold)
                            .foregroundColor(.white)

//                        Text("Justice & Public Safety")
//                            .font(.subheadline)
//                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.top, 48)

                    // ── Card ─────────────────────────────────────────────
                    VStack(spacing: 0) {
                        // Tab picker
                        Picker("", selection: $selectedTab) {
                            Text("Login").tag(0)
                            Text("Register").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 8)

                        if selectedTab == 0 {
                            LoginFormView()
                        } else {
                            RegisterFormView()
                        }
                    }
                    .background(Color.appSystemBackground)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.18), radius: 16, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Login Form

private struct LoginFormView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    enum Field { case username, password }

    var body: some View {
        VStack(spacing: 16) {
            JPSTextField(icon: "person", placeholder: "Username", text: $username)
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }

            JPSTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { doLogin() }

            if let err = auth.errorMessage {
                ErrorBanner(message: err)
            }

            Button(action: doLogin) {
                JPSButton(label: "Login", isLoading: auth.isLoading)
            }
            .disabled(auth.isLoading)
        }
        .padding(20)
    }

    private func doLogin() {
        focusedField = nil
        Task { await auth.login(username: username, password: password) }
    }
}

// MARK: - Register Form

private struct RegisterFormView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    enum Field { case username, fullName, email, password, confirm }

    var body: some View {
        VStack(spacing: 16) {
            JPSTextField(icon: "person", placeholder: "Username *", text: $username)
                .focused($focusedField, equals: .username)
                .submitLabel(.next).onSubmit { focusedField = .fullName }

            JPSTextField(icon: "person.text.rectangle", placeholder: "Full Name", text: $fullName)
                .focused($focusedField, equals: .fullName)
                .submitLabel(.next).onSubmit { focusedField = .email }

            JPSTextField(icon: "envelope", placeholder: "Email *", text: $email, isEmail: true)
                .focused($focusedField, equals: .email)
                .submitLabel(.next).onSubmit { focusedField = .password }

            JPSTextField(icon: "lock", placeholder: "Password *", text: $password, isSecure: true)
                .focused($focusedField, equals: .password)
                .submitLabel(.next).onSubmit { focusedField = .confirm }

            JPSTextField(icon: "lock.fill", placeholder: "Confirm Password *", text: $confirmPassword, isSecure: true)
                .focused($focusedField, equals: .confirm)
                .submitLabel(.go).onSubmit { doRegister() }

            if let err = auth.errorMessage {
                ErrorBanner(message: err)
            }

            Button(action: doRegister) {
                JPSButton(label: "Create Account", isLoading: auth.isLoading)
            }
            .disabled(auth.isLoading)
        }
        .padding(20)
    }

    private func doRegister() {
        focusedField = nil
        guard password == confirmPassword else {
            auth.errorMessage = "Passwords do not match."
            return
        }
        Task {
            await auth.register(username: username, email: email, fullName: fullName, password: password)
        }
    }
}

// MARK: - Shared UI Components

struct JPSTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isEmail: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
                
            } else {
                inputField
            }
        }
        .padding(14)
        .background(Color.appSecondarySystemBackground)
        .cornerRadius(12)
    }

    @ViewBuilder
    private var inputField: some View {
        #if os(iOS)
        TextField(placeholder, text: $text)
            .autocapitalization(.none)
            .keyboardType(isEmail ? .emailAddress : .default)
            .autocorrectionDisabled()
        #else
        TextField(placeholder, text: $text)
            .autocorrectionDisabled()
        #endif
    }
}

struct JPSButton: View {
    let label: String
    var isLoading: Bool = false

    var body: some View {
        HStack {
            if isLoading {
                ProgressView().tint(.white)
            }
            Text(isLoading ? "Please wait…" : label)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color(hex: "1A3A5C"))
        .foregroundColor(.white)
        .cornerRadius(12)
    }
}

struct ErrorBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message).font(.footnote)
        }
        .foregroundColor(.white)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.85))
        .cornerRadius(10)
    }
}

// MARK: - Color Helper

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double(rgb         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static var appSystemBackground: Color {
        #if canImport(UIKit)
        Color(UIColor.systemBackground)
        #else
        Color(NSColor.windowBackgroundColor)
        #endif
    }

    static var appSecondarySystemBackground: Color {
        #if canImport(UIKit)
        Color(UIColor.secondarySystemBackground)
        #else
        Color(NSColor.controlBackgroundColor)
        #endif
    }
}
