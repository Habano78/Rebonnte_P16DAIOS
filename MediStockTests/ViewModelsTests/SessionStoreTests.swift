//
//  SessionStoreTests.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//
import Testing
import Foundation
@testable import MediStock

@Suite("Tests du SessionStore")
@MainActor
struct SessionStoreTests {
        
        @Test("Initialisation et écoute de la session")
        func testSessionUpdateOnListen() async {
                // GIVEN
                let mockAuth = MockAuthService()
                let store = SessionStore(authService: mockAuth)
                
                // WHEN
                store.listen()
                
                // THEN
                #expect(store.currentError == nil)
        }
        
        @Test("Déconnexion et nettoyage des données")
        func testSignOutClearsSession() {
                // GIVEN
                let mockAuth = MockAuthService()
                let store = SessionStore(authService: mockAuth)
                
                store.session = User(id: "123", email: "test@medistock.com")
                store.userEmail = "test@medistock.com"
                
                // WHEN
                store.signOut()
                
                // THEN
                #expect(store.session == nil, "La session doit être effacée")
                #expect(store.userEmail == nil, "L'email doit être nettoyé")
        }
        
        @Test("Le SessionStore se met à jour quand le flux d'auth change")
        func testSessionStoreReactsToStream() async throws {
                // GIVEN
                let mockAuth = MockAuthService()
                let store = SessionStore(authService: mockAuth)
                
                await Task.yield()
                try await Task.sleep(for: .milliseconds(20))
                
                // WHEN
                let expectedUser = User(id: "stream_1", email: "flux@test.com")
                mockAuth.simulateUserChange(expectedUser)
                
                await Task.yield()
                try await Task.sleep(for: .milliseconds(100))
                
                // THEN
                #expect(store.userEmail == "flux@test.com", "L'email aurait dû être mis à jour par le flux.")
        }
        
        @Test("Capture de l'erreur en cas d'échec de déconnexion")
        func testSignOutFailureSetsError() {
            // GIVEN
            let mockAuth = MockAuthService()
            mockAuth.shouldFail = true
            let store = SessionStore(authService: mockAuth)
            
            // WHEN
            store.signOut()
            
            // THEN
            #expect(store.currentError != nil)
            if case .signOutFailed = store.currentError {

            } else {
                Issue.record("L'erreur devrait être de type .signOutFailed")
            }
        }
}
