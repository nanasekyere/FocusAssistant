//
//  SignInView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI
import FirebaseAuth
import ButtonKit

struct SignInView: View {
    @Environment(AuthVM.self) private var vm
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmingPassword: String = ""
    @State private var signingUp: Bool = false
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        @Bindable var vm = vm
        NavigationStack {
            VStack(spacing: 15){
                Text("Focus Assistant")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(alignment: .top)
                    .padding(.bottom)
                
                Group {
                    if signingUp {
                        HStack {
                            GlassEffectContainer {
                                TextField("First Name", text: $firstName)
                                    .autocapitalization(.none)
                                    .textContentType(.emailAddress)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .glassEffect(.regular.interactive())
                                
                                TextField("Last Name", text: $lastName)
                                    .autocapitalization(.none)
                                    .textContentType(.emailAddress)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .glassEffect(.regular.interactive())
                            }
                        }
                    }
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.interactive())
                    
                    SecureField("Password", text: $password)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .textContentType(isDebug() ? .none : .password)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.interactive())
                    
                    if signingUp {
                        SecureField("Confirm Password", text: $confirmingPassword)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .textContentType(isDebug() ? .none : .password)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassEffect(.regular.interactive())
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .clipShape(.capsule)
                .animation(.easeInOut, value: signingUp)
                
                Button("Trouble logging in?") {
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .tint(.primary)
                .font(.callout)
                .fontWeight(.regular)
                
                Group {
                    AsyncButton {
                        if signingUp {
                            if password != confirmingPassword {
                                vm.errorMessage = "Passwords don't match"
                                vm.showError.toggle()
                            } else {
                                try await vm.createUser(withEmail: email, password: password, fullname: firstName + " " + lastName)
                            }
                        } else {
                            try await vm.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        Text(signingUp ? "Sign Up" : "Sign In")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .foregroundStyle(.background)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.primary)
                    .asyncButtonStyle(.pulse)
                    .disabledWhenLoading()
                    .throwableButtonStyle(.shake)
                    .glassEffect(.regular.interactive())
                }
                .padding(.horizontal, 15)
                
                HStack (spacing: 4) {
                    Text(signingUp ? "Already have an account?" : "Don't have an account?")
                    
                    Button(signingUp ? "Log In" :"Sign Up") {
                        withAnimation(.easeInOut) {
                            signingUp.toggle()
                        }
                    }
                    .underline()
                    .tint(.primary)
                }
                .animation(.easeInOut, value: signingUp)
           
            }
        }
        .padding(.horizontal, 20)
        .alert("Login error", isPresented: $vm.showError) {
            Button("OK") {
                vm.showError = false
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }
}

extension SignInView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && !password.isEmpty && email.contains("@") && password.count >= 6
    }
}

#Preview {
    SignInView()
        .environment(AuthVM())
}
