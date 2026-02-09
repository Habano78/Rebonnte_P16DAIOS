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
        func fetchMedicines(
                userId: String,
                category: MedicineCategory?,
                sortBy: SortOption,
                descending: Bool,
                limit: Int,
                lastCursor: Any?
        ) async throws -> (medicines: [Medicine], lastCursor: Any?)
        
        func saveMedicine(_ medicine: Medicine) async throws
        func deleteMedicine(id: String) async throws
        func updateStock(medicineId: String, newStock: Int) async throws
}

//MARK: Implementation
final class MedicineService: MedicineServiceProtocol {
        
        private let db = Firestore.firestore()
        
        
        func fetchMedicines(
                userId: String,
                category: MedicineCategory? = nil,
                sortBy: SortOption = .name,
                descending: Bool = false,
                limit: Int = 20,
                lastCursor: Any? = nil
        ) async throws -> (medicines: [Medicine], lastCursor: Any?) {
                
                var query: Query = db.collection("medicines")
                
                query = query.whereField("userId", isEqualTo: userId)
                if let category = category {
                        query = query.whereField("category", isEqualTo: category.rawValue)
                }
                query = query.order(by: sortBy.rawValue, descending: descending)
                query = query.limit(to: limit)
                
                if let lastSnapshot = lastCursor as? DocumentSnapshot {
                        query = query.start(afterDocument: lastSnapshot)
                }
                
                let snapshot = try await query.getDocuments()
                
                let medicines = snapshot.documents.compactMap { doc -> Medicine? in
                        guard let dto = try? doc.data(as: MedicineDTO.self) else { return nil }
                        return dto.toModel()
                }
                
                return (medicines, snapshot.documents.last)
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
        let userId: String
        let name: String
        let brand: String
        let stock: Int
        let aisle: String
        let alertThreshold: Int
        let category: MedicineCategory
        let expirationDate: Date?
        
        init(from model: Medicine) {
                self.id = model.id
                self.userId = model.userId
                self.name = model.name
                self.brand = model.brand
                self.stock = model.stock
                self.aisle = model.aisle
                self.alertThreshold = model.alertThreshold
                self.category = model.category
                self.expirationDate = model.expirationDate
        }
        
        func toModel() -> Medicine {
                Medicine(
                        id: id ?? UUID().uuidString,
                        userId: userId,
                        name: name,
                        brand: brand,
                        stock: stock,
                        aisle: aisle,
                        alertThreshold: alertThreshold,
                        category: category,
                        expirationDate: expirationDate
                )
        }
}

enum SortOption: String, CaseIterable, Identifiable {
        case name = "name"
        case brand = "brand"
        case category = "category"
        case stock = "stock"
        case expirationDate = "expirationDate"
        
        var id: String { self.rawValue }
        
        var displayName: String {
                switch self {
                case .name: return "Nom"
                case .brand: return "Marque"
                case .category: return "Catégorie"
                case .stock: return "Stock"
                case .expirationDate: return "Date de péremption"
                }
        }
}
