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
@MainActor
protocol MedicineServiceProtocol: Sendable {
        func fetchMedicines() async throws -> [Medicine]
        func saveMedicine(_ medicine: Medicine) async throws
        func deleteMedicine(id: String) async throws
        func updateStock(medicineId: String, newStock: Int) async throws
}

//MARK: Implementation
final class MedicineService: MedicineServiceProtocol {
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
                try db.collection("medicines").document(medicine.id ?? "").setData(from: dto)
        }
        
        func deleteMedicine(id: String) async throws {
                try await db.collection("medicines").document(id).delete()
        }
        
        func updateStock(medicineId: String, newStock: Int) async throws {
                try await db.collection("medicines").document(medicineId).updateData([
                        "stock": newStock
                ])
        }
}

// MARK: - DTO & Mapping
private struct MedicineDTO: Codable {
        @DocumentID var id: String?
        let name: String
        let brand: String
        let stock: Int
        let aisle: String
        let alertThreshold: Int
        let category: MedicineCategory
        let expirationDate: Date?
        
        init(from model: Medicine) {
                self.id = model.id
                self.name = model.name
                self.brand = model.brand
                self.stock = model.stock
                self.aisle = model.aisle
                self.alertThreshold = model.alertThreshold
                self.category = model.category
                self.expirationDate = model.expirationDate
        }
}
private extension Medicine {
        init(dto: MedicineDTO) {
                self.init(id: dto.id ?? UUID().uuidString,
                          name: dto.name,
                          brand: dto.brand,
                          stock: dto.stock,
                          aisle: dto.aisle,
                          alertThreshold: dto.alertThreshold,
                          category: dto.category)
        }
}
