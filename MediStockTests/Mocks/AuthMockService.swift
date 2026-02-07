//
//  AuthMockService.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Foundation
@testable import MediStock


//MARK: Auth Service

@MainActor
final class MockAuthService: AuthServiceProtocol {
        
        //MARK: Properties
        private var continuation: AsyncStream<User?>.Continuation?
        var shouldFail = false
        var authErrorToThrow: AuthServiceError = .userNotFound
        
        
        //MARK: Actions
        func userStream() -> AsyncStream<User?> {
                AsyncStream { continuation in
                        self.continuation = continuation
                }
        }
        
        func signIn(email: String, password: String) async throws -> User {
                if shouldFail { throw authErrorToThrow }
                return User(id: "1", email: email)
        }
        
        func signUp(email: String, password: String) async throws -> User {
                if shouldFail { throw MockError.testFailure }
                return User(id: "1", email: email)
        }
        
        func signOut() throws {
                if shouldFail { throw MockError.testFailure }
        }
        
        func observeAuthState(completion: @escaping (User?) -> Void) -> (any NSObjectProtocol)? { nil }
        func removeAuthStateListener(_ handle: any NSObjectProtocol) { }
        
        
        func simulateUserChange(_ user: User?) {
                continuation?.yield(user)
        }
}

