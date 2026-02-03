//
//  MedicineServiceProtocol.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation
@preconcurrency import FirebaseFirestore
import FirebaseFirestoreSwift

//MARK: Protocol
protocol MedicineServiceProtocol: Sendable {
        func fetchMedicines() async throws -> [Medicine]
        func saveMedicine(_ medicine: Medicine) async throws
        func deleteMedicine(id: String) async throws
}

//MARK: Implementation
final class FirebaseMedicineService: MedicineServiceProtocol {
        private let db = Firestore.firestore()
        
        func fetchMedicines() async throws -> [Medicine] {
                let snapshot = try await db.collection("medicines").getDocuments()
                return snapshot.documents.compactMap { doc in
                        guard let dto = try? doc.data(as: MedicineDTO.self) else { return nil }
                        return Medicine(dto: dto)
                }
        }
        
        func saveMedicine(_ medicine: Medicine) async throws {
                let dto = MedicineDTO(from: medicine)
                try db.collection("medicines").document(medicine.id).setData(from: dto)
        }
        
        func deleteMedicine(id: String) async throws {
                try await db.collection("medicines").document(id).delete()
        }
}

// MARK: - DTO & Mapping
private struct MedicineDTO: Codable {
        @DocumentID var id: String?
        let name: String
        let stock: Int
        let aisle: String
        
        init(from model: Medicine) {
                self.id = model.id
                self.name = model.name
                self.stock = model.stock
                self.aisle = model.aisle
        }
}

private extension Medicine {
        init(dto: MedicineDTO) {
                self.init(id: dto.id ?? UUID().uuidString, name: dto.name, stock: dto.stock, aisle: dto.aisle)
        }
}
