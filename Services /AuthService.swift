//
//  AuthService.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation
@preconcurrency import FirebaseAuth

enum AuthError: Error, LocalizedError {
        case invalidEmail
        case weakPassword
        case userNotFound
        case wrongPassword
        case unknown(String)
        
        var errorDescription: String? {
                switch self {
                case .invalidEmail: return "L'adresse email est mal formée."
                case .weakPassword: return "Le mot de passe est trop simple."
                case .userNotFound: return "Aucun compte ne correspond à cet email."
                case .wrongPassword: return "Le mot de passe est incorrect."
                case .unknown(let message): return message
                }
        }
}

//MARK
/// Contrat pour la gestion de l'identité utilisateur
protocol AuthServiceProtocol: Sendable {
        func observeAuthState(completion: @escaping @Sendable (User?) -> Void) -> AuthStateDidChangeListenerHandle
        func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
        
        @MainActor func signIn(email: String, password: String) async throws -> User
        @MainActor func signUp(email: String, password: String) async throws -> User
        func signOut() throws
}

final class FirebaseAuthService: AuthServiceProtocol {
        private let auth = Auth.auth()
        
        func observeAuthState(completion: @escaping @Sendable (User?) -> Void) -> AuthStateDidChangeListenerHandle {
                return auth.addStateDidChangeListener { _, firebaseUser in
                        if let user = firebaseUser {
                                completion(User(id: user.uid, email: user.email ?? ""))
                        } else {
                                completion(nil)
                        }
                }
        }
        
        func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
                auth.removeStateDidChangeListener(handle)
        }
        
        /// Connecte un utilisateur et traduit les erreurs Firebase en erreurs métier
        @MainActor
        func signIn(email: String, password: String) async throws -> User {
                do {
                        let result = try await auth.signIn(withEmail: email, password: password)
                        return User(id: result.user.uid, email: result.user.email ?? "")
                } catch {
                        throw mapError(error)
                }
        }
        
        @MainActor
        func signUp(email: String, password: String) async throws -> User {
                do {
                        let result = try await auth.createUser(withEmail: email, password: password)
                        return User(id: result.user.uid, email: result.user.email ?? "")
                } catch {
                        throw mapError(error)
                }
        }
        
        func signOut() throws {
                try auth.signOut()
        }
        
        // MARK: - Private Helpers
        private func mapError(_ error: Error) -> AuthError {
                let code = (error as NSError).code
                switch AuthErrorCode.Code(rawValue: code) {
                case .invalidEmail: return .invalidEmail
                case .weakPassword: return .weakPassword
                case .wrongPassword: return .wrongPassword
                case .userNotFound: return .userNotFound
                default: return .unknown(error.localizedDescription)
                }
        }
}
