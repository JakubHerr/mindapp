//
//  AuthManager.swift
//  MindApp
//
//  Created by Michael Slavev on 22.03.2024.
//

import Foundation
import Supabase

/// Manager class that contains funtions regarding authentification of users
class AuthManager {
    static let shared = AuthManager()
    
    /// Function for getting the current user session of supabase
    /// - Returns: `Session` which is currently used to fetch data
    func CurrentUser() async throws -> Session {
        do {
            return try await supabase.auth.session
        } catch {
            throw error
        }
    }
    
    /// Function for user signing in
    /// - Parameters:
    ///   - email: `String` containing the email of the user trying to sign in
    ///   - password: `String` containing the password of the user trying to sign in
    func SignIn(email: String, password: String) async throws {
        do {
            try await supabase.auth.signIn(email: email.lowercased(), password: password)
        } catch {
            throw error
        }
    }
    
    /// Function for user to sign up
    /// - Parameters:
    ///   - email: `String` containing the email of the new user
    ///   - password: `String` containing the password of the new user
    ///   - userInfo: To be honest, am not sure, if you see this and know, rewrite it please
    func SignUp(email: String, password: String, userInfo: [String: AnyJSON]) async throws {
        do {
            try await supabase.auth.signUp(email: email.lowercased(), password: password, data: userInfo)
        } catch {
            throw error
        }
    }
    
    /// Function for user to sign out of his account in the app
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
        } catch {
            throw error
        }
    }
    
    //MARK: Getters for ease of use
    func fetchUserInfo() async throws -> String? {
        let session = try await CurrentUser()
        return session.user.id.uuidString
    }
}
