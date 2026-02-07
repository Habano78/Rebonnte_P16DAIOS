//
//  MedicineMockService.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Foundation
@testable import MediStock

enum MockError: Error { case testFailure }

//MARK: Medicine Service
@MainActor
final class MockMedicineService: MedicineServiceProtocol {
        
        var shouldFail = false
        var medicinesToReturn: [Medicine] = []
        
        func fetchMedicines() async throws -> [Medicine] {
                if shouldFail { throw MockError.testFailure }
                return medicinesToReturn
        }
        
        func saveMedicine(_ medicine: Medicine) async throws {
                if shouldFail { throw MockError.testFailure }
        }
        
        func deleteMedicine(id: String) async throws {
                if shouldFail { throw MockError.testFailure }
        }
        
        func updateStock(medicineId: String, newStock: Int) async throws {
                if shouldFail { throw MockError.testFailure }
        }
}
