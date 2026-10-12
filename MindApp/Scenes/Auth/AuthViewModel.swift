//
//  AuthViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 22.03.2024.
//

import Combine
import Foundation
import Supabase

enum AuthState: Hashable {
    case Initial
    case SignedIn
    case SignedOut
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Injected private var authManager: AuthManager
    
    @Published var errorMessage: String = ""
    @Published var authState: AuthState = .Initial
    @Published var isLoading = false
    
    var cancellable = Set<AnyCancellable>()
    
    func isUserSignIn() async {
        do {
            let _ = try await authManager.CurrentUser()
            authState = AuthState.SignedIn
            
        } catch _ {
            authState = AuthState.SignedOut
        }
    }
    
    func signup(email: String, password: String) async {
        do {
            isLoading = true
            try await authManager.SignUp(email: email, password: password, userInfo: ["Hola": "Senor"])
            authState = AuthState.SignedIn
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            isLoading = true
            try await authManager.SignIn(email: email, password: password)
            
            authState = AuthState.SignedIn
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func validEmail(email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isEmailValid = email.range(of: emailRegex, options: .regularExpression) != nil
        
        return isEmailValid
    }
    
    func validPassword(password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*\\.).{8,}$"
        let isPasswordValid = password.range(of: passwordRegex, options: .regularExpression) != nil
        
        return isPasswordValid
    }
    
    func doesPasswordMatch(password: String, passwordConfirm: String) -> Bool {
        return password == passwordConfirm
    }
    
    func signoutUser() async {
        do {
            try await authManager.signOut()
            authState = AuthState.SignedOut
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    static func mock() -> AuthViewModel {
        AuthViewModel()
    }
}
