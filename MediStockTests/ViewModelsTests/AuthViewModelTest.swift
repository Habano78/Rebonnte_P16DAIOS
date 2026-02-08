//
//  AuthViewModelTest.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Testing
import Foundation
@testable import MediStock


@Suite("Tests du AuthViexwModel")
@MainActor
struct AuthViewModelTests {
        //MARK: Tests Authentification Service
        
        @Test("Connexion réussie")
        func testSignInSuccess() async {
                // GIVEN
                let mockAuth = MockAuthService()
                let mockUser = MockUserService()
                let vm = AuthViewModel(authService: mockAuth, userService: mockUser)
                vm.email = "test@medistock.com"
                vm.password = "password123"
                
                // WHEN
                await vm.signIn()
                
                // THEN
                #expect(vm.errorMessage == nil)
                #expect(vm.isLoading == false)
        }
        
        @Test("Échec de connexion (Message d'erreur)")
        func testSignInFailure() async {
                // GIVEN
                let mockAuth = MockAuthService()
                mockAuth.shouldFail = true
                let vm = AuthViewModel(authService: mockAuth, userService: MockUserService())
                
                // WHEN
                await vm.signIn()
                
                // THEN
                #expect(vm.errorMessage != nil, "Un message d'erreur doit être présent")
                #expect(vm.isLoading == false)
        }
        
        @Test("Inscription réussie et synchronisation du compte")
        func testSignUpSuccessAndSync() async {
                // GIVEN
                let mockAuth = MockAuthService()
                let mockUser = MockUserService()
                let vm = AuthViewModel(authService: mockAuth, userService: mockUser)
                vm.email = "new@medistock.com"
                vm.password = "securePass123"
                
                // WHEN
                await vm.signUp()
                
                // THEN
                #expect(vm.errorMessage == nil)
                #expect(mockUser.wasSyncCalled == true, "Le service utilisateur doit être synchronisé après l'inscription")
        }
        
        @Test("Vérifier le mapping des messages d'erreur spécifiques (AuthServiceError)")
        func testAuthServiceErrorDescriptionMapping() async {
            // GIVEN
            let mockAuth = MockAuthService()
            mockAuth.shouldFail = true
            mockAuth.authErrorToThrow = .userNotFound
            
            let vm = AuthViewModel(authService: mockAuth, userService: MockUserService())

            // WHEN
            await vm.signIn()

            // THEN
            #expect(vm.errorMessage == AuthServiceError.userNotFound.errorDescription)
            #expect(vm.isLoading == false)
        }
        
        @Test("Échec de synchronisation après inscription réussie")
        func testSignUpSyncFailure() async {
            let mockAuth = MockAuthService()
            let mockUser = MockUserService()
            mockUser.shouldFail = true 
            
            let vm = AuthViewModel(authService: mockAuth, userService: mockUser)
            await vm.signUp()
            
            #expect(vm.errorMessage != nil, "L'erreur de synchronisation doit être capturée")
            #expect(vm.isLoading == false)
        }
}
