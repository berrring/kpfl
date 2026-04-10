//
//  AuthScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct AuthScreen: View {
    @EnvironmentObject private var store: DataStore
    let onBack: () -> Void
    let onSignedIn: () -> Void

    enum Mode { case signin, register }

    @State private var mode: Mode = .signin
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var remember: Bool = true
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: mode == .signin ? "Sign In" : "Register", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    logoBlock

                    KPCard {
                        VStack(spacing: 12) {
                            if mode == .register {
                                textField(title: "Full Name", text: $name, placeholder: "Enter your name")
                            }
                            textField(title: "Email Address", text: $email, placeholder: "you@example.com")
                            secureField(title: "Password", text: $password, placeholder: "••••••••")

                            if mode == .signin {
                                HStack {
                                    Toggle("Remember me", isOn: $remember)
                                        .font(.system(size: 12, weight: .semibold))
                                        .tint(Color(hex: "#E8A912"))
                                    Spacer()
                                    Button("Forgot password?") { }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color(hex: "#E8A912"))
                                }
                            }

                            Button {
                                Task { await submit() }
                            } label: {
                                Text(isSubmitting ? "Please wait..." : (mode == .signin ? "Sign In" : "Create Account"))
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(hex: "#0A1628"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(isSubmitting)

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(spacing: 6) {
                                Text(mode == .signin ? "Don't have an account?" : "Already have an account?")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                                Button(mode == .signin ? "Register" : "Sign In") {
                                    mode = (mode == .signin ? .register : .signin)
                                }
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(Color(hex: "#E8A912"))
                            }
                        }
                    }

                    Text("By continuing, you agree to KPFL's Terms and Privacy Policy")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }

    private var logoBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "#F5C742"), Color(hex: "#E8A912")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("KPFL")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color(hex: "#0A1628"))
            }
            .frame(width: 64, height: 64)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

            Text(mode == .signin ? "Welcome Back" : "Join KPFL")
                .font(.system(size: 20, weight: .black))
            Text(mode == .signin ? "Sign in to your account" : "Create your account")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func submit() async {
        let okSignIn = mode == .signin && email.contains("@") && password.count >= 6
        let okRegister = mode == .register && !name.isEmpty && email.contains("@") && password.count >= 6

        if okSignIn {
            isSubmitting = true
            defer { isSubmitting = false }
            if await store.login(email: email, password: password) {
                onSignedIn()
            } else {
                errorMessage = store.authErrorMessage ?? "Sign in failed"
            }
        } else if okRegister {
            isSubmitting = true
            defer { isSubmitting = false }
            if await store.register(name: name, email: email, password: password) {
                onSignedIn()
            } else {
                errorMessage = store.authErrorMessage ?? "Registration failed"
            }
        } else {
            errorMessage = "Проверьте email и пароль"
        }
    }

    private func textField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func secureField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
            SecureField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
