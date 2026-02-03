//
//  UserService.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation
@preconcurrency import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: Protocol
/// Définit les capacités de gestion des profils opérateurs du groupe Rebonnté.
protocol UserServiceProtocol: Sendable {
        /// Enregistre ou met à jour les informations de l'opérateur (Email, Nom) dans Firestore.
        func syncUser(_ user: User) async throws
        
        /// Récupère les informations d'un opérateur via son identifiant pour enrichir l'historique.
        func fetchUser(id: String) async throws -> User?
}

// MARK: - Implementation
final class FirebaseUserService: UserServiceProtocol {
        /// Référence à la base de données Firestore.
        private let db = Firestore.firestore()
        
        /// Synchronise les données de l'utilisateur connecté pour qu'elles soient accessibles par les autres services.
        func syncUser(_ user: User) async throws {
                let dto = UserDTO(from: user)
                // On utilise l'UID de l'authentification comme ID de document pour la collection "users".
                try db.collection("users").document(user.id).setData(from: dto, merge: true)
        }
        
        /// Récupère un profil utilisateur. Utile pour transformer un UID technique en email lisible.
        func fetchUser(id: String) async throws -> User? {
                let snapshot = try await db.collection("users").document(id).getDocument()
                
                // Vérifie si le document existe et tente le décodage vers le DTO.
                guard snapshot.exists,
                      let dto = try? snapshot.data(as: UserDTO.self) else {
                        return nil
                }
                
                // Retourne le modèle de domaine mappé.
                return User(id: id, email: dto.email, fullName: dto.fullName)
        }
}

// MARK: - Data Transfer Object (DTO)
/// Structure privée dédiée à la représentation des données dans Firestore.
private struct UserDTO: Codable {
        let email: String
        let fullName: String?
        
        init(from model: User) {
                self.email = model.email
                self.fullName = model.fullName
        }
}
