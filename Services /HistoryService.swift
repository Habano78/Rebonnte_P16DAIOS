//
//  HistoryService.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation
@preconcurrency import FirebaseFirestore
import FirebaseFirestoreSwift

//MARK: Protocol
//@MainActor
protocol HistoryServiceProtocol: Sendable {
        func fetchMedicineHistory(for medicineId: String) async throws -> [HistoryEntry]
        func fetchAllHistory() async throws -> [HistoryEntry]
        func addEntry(_ entry: HistoryEntry) async throws
        func addToHistory(action: String, medicineId: String, userEmail: String, details: String) async
}

//MARK: Implementation
final class HistoryService: HistoryServiceProtocol {
        private let db = Firestore.firestore()
        
        func fetchMedicineHistory(for medicineId: String) async throws -> [HistoryEntry] {
                let snapshot = try await db.collection("history")
                        .whereField("medicineId", isEqualTo: medicineId)
                        .order(by: "timestamp", descending: true)
                        .getDocuments()
                
                return snapshot.documents.compactMap { doc in
                        guard let dto = try? doc.data(as: HistoryEntryDTO.self) else { return nil }
                        return HistoryEntry(dto: dto)
                }
        }
        
        func fetchAllHistory() async throws -> [HistoryEntry] {
                let snapshot = try await db.collection("history")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 50)
                        .getDocuments()
                
                return snapshot.documents.compactMap { doc in
                        guard let dto = try? doc.data(as: HistoryEntryDTO.self) else { return nil }
                        return HistoryEntry(dto: dto)
                }
        }
        
        func addEntry(_ entry: HistoryEntry) async throws {
                let dto = HistoryEntryDTO(from: entry)
                try db.collection("history").addDocument(from: dto)
        }
        
        func addToHistory(action: String, medicineId: String, userEmail: String, details: String) async {
                let data: [String: Any] = [
                        "action": action,
                        "medicineId": medicineId,
                        "userEmail": userEmail,
                        "details": details,
                        "timestamp": Timestamp(date: Date())
                ]
                
                do {
                        try await db.collection("history").addDocument(data: data)
                        print("Historique mis à jour : \(action)")
                } catch {
                        print("Erreur historique : \(error.localizedDescription)")
                }
        }
}

// MARK: DTO + Mapping
private struct HistoryEntryDTO: Codable {
        @DocumentID var id: String?
        let medicineId: String
        let userEmail: String
        let action: String
        let details: String
        let timestamp: Date
        
        init(from model: HistoryEntry) {
                self.id = model.id
                self.medicineId = model.medicineId
                self.userEmail = model.userEmail
                self.action = model.action
                self.details = model.details
                self.timestamp = model.timestamp
        }
}

private extension HistoryEntry {
        init(dto: HistoryEntryDTO) {
                self.init(id: dto.id ?? UUID().uuidString, medicineId: dto.medicineId, userEmail: dto.userEmail, action: dto.action, details: dto.details, timestamp: dto.timestamp)
        }
}
