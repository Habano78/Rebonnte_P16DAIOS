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
@MainActor
protocol UserServiceProtocol: Sendable {
        func syncUser(_ user: User) async throws
        func fetchUser(id: String) async throws -> User?
}

// MARK: Implementation
final class UserService: UserServiceProtocol {
        
        private let db = Firestore.firestore()
        
        func syncUser(_ user: User) async throws {
                let dto = UserDTO(from: user)
                try db.collection("users").document(user.id).setData(from: dto, merge: true)
        }
        
        func fetchUser(id: String) async throws -> User? {
                let snapshot = try await db.collection("users").document(id).getDocument()
                
                guard snapshot.exists,
                      let dto = try? snapshot.data(as: UserDTO.self) else {
                        return nil
                }
                
                return User(id: id, email: dto.email, fullName: dto.fullName)
        }
}

// MARK: DTO
private struct UserDTO: Codable {
        let email: String
        let fullName: String?
        
        init(from model: User) {
                self.email = model.email
                self.fullName = model.fullName
        }
}
