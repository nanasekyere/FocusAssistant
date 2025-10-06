//
//  SignInView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var vm: SignInVM = .init()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmingPassword: String = ""
    @State private var signingUp: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15){
                Text("Focus Assistant")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(alignment: .top)
                    .padding(.bottom)
                
                Group {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.interactive())
                    
                    SecureField("Password", text: $password)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .textContentType(.password)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.interactive())
                    
                    if signingUp {
                        SecureField("Confirm Password", text: $confirmingPassword)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .textContentType(.password)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassEffect(.regular.interactive())
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .animation(.easeInOut, value: signingUp)
                
                Button("Trouble logging in?") {
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .tint(.primary)
                .font(.callout)
                .fontWeight(.regular)
                
                Button {
                    if signingUp {
                        vm.signUp(email: email, password: password)
                    } else {
                        vm.signIn(email: email, password: password)
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
                .glassEffect(.regular.interactive())
                
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
        .alert("Sign in error", isPresented: $vm.showError) {
            Button("OK") {}
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    SignInView()
}
