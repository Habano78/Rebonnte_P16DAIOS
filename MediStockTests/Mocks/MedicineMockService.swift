//
//  MedicineMockService.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Foundation
@testable import MediStock

enum MockError: Error { case testFailure }

// MARK: - Mock Medicine Service
@MainActor
final class MockMedicineService: MedicineServiceProtocol {
    
    // Propriétés de contrôle pour les tests
    var shouldFail = false
    var medicinesToReturn: [Medicine] = []
    

    func fetchMedicines(
        userId: String,
        category: MedicineCategory?,
        sortBy: SortOption,
        descending: Bool,
        limit: Int,
        lastCursor: Any?
    ) async throws -> (medicines: [Medicine], lastCursor: Any?) {
        
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        }
        
        return (medicinesToReturn, nil)
    }
    
    func saveMedicine(_ medicine: Medicine) async throws {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
    }
    
    func deleteMedicine(id: String) async throws {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
    }
    
    func updateStock(medicineId: String, newStock: Int) async throws {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
        
        if let index = medicinesToReturn.firstIndex(where: { $0.id == medicineId }) {
            medicinesToReturn[index].stock = newStock
        }
    }
}

