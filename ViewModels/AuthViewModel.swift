//
//  AuthViewModel.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
        var email = ""
        var password = ""
        var isLoading = false
        var errorMessage: String?
        
        private let authService: any AuthServiceProtocol
        private let userService: any UserServiceProtocol
        
        init(authService: any AuthServiceProtocol, userService: any UserServiceProtocol) {
                self.authService = authService
                self.userService = userService
        }
        
        func signIn() async {
                isLoading = true
                errorMessage = nil
                do {
                        _ = try await authService.signIn(email: email, password: password)
                } catch {
                        self.errorMessage = error.localizedDescription
                }
                isLoading = false
        }
        
        func signUp() async {
                print("➡️ [AuthVM] Début de la procédure signUp")
                isLoading = true
                errorMessage = nil
                
                do {
                        // Étape 1 : Création technique
                        let user = try await authService.signUp(email: email, password: password)
                        print("✅ [AuthVM] Étape 1 réussie : Utilisateur créé dans Firebase Auth")
                        
                        // Étape 2 : Création du profil
                        try await userService.syncUser(user)
                        print("✅ [AuthVM] Étape 2 réussie : Profil synchronisé dans Firestore")
                        
                } catch {
                        // On inspecte l'objet error complet pour voir le domaine et le code
                        let nsError = error as NSError
                        print("❌ [DÉTAILS ERREUR]")
                        print("Domaine: \(nsError.domain)")
                        print("Code: \(nsError.code)")
                        print("Description: \(nsError.localizedDescription)")
                        
                        // Si tu as accès aux infos supplémentaires de Firebase
                        if let detailedError = nsError.userInfo[NSLocalizedFailureReasonErrorKey] {
                                print("Raison: \(detailedError)")
                        }
                        
                        self.errorMessage = error.localizedDescription
                }
                isLoading = false
        }
}
