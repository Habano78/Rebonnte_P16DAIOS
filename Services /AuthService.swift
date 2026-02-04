//
//  AuthService.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation
@preconcurrency import FirebaseAuth

// MARK: - Erreurs d'Authentification
enum AuthServiceError: Error, LocalizedError {
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

// MARK: - Protocol
protocol AuthServiceProtocol: Sendable {
        func userStream() -> AsyncStream<User?>
        func signIn(email: String, password: String) async throws -> User
        func signUp(email: String, password: String) async throws -> User
        func signOut() throws
        func observeAuthState(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle?
        func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
}

// MARK: - Implementation
final class FirebaseAuthService: AuthServiceProtocol {
        private let auth = Auth.auth()
        
        func userStream() -> AsyncStream<User?> {
                AsyncStream { continuation in
                        let handle = auth.addStateDidChangeListener { _, firebaseUser in
                                let user = firebaseUser.map { User(id: $0.uid, email: $0.email ?? "") }
                                continuation.yield(user)
                        }
                        continuation.onTermination = { @Sendable _ in
                                Auth.auth().removeStateDidChangeListener(handle)
                        }
                }
        }
        
        func signIn(email: String, password: String) async throws -> User {
                do {
                        let result = try await auth.signIn(withEmail: email, password: password)
                        return User(id: result.user.uid, email: result.user.email ?? "")
                } catch {
                        
                        throw mapError(error)
                }
        }
        
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
        
        func observeAuthState(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle? {
                return auth.addStateDidChangeListener { _, firebaseUser in
                        let user = firebaseUser.map { User(id: $0.uid, email: $0.email ?? "") }
                        completion(user)
                }
        }
        
        func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
                auth.removeStateDidChangeListener(handle)
        }
        
        // MARK: - Private Helper
        
        private func mapError(_ error: Error) -> AuthServiceError {
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
