//
//  HistoryMockService.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Foundation
@testable import MediStock


@MainActor
final class MockHistoryService: HistoryServiceProtocol {
        var shouldFail = false
        var historyToReturn: [HistoryEntry] = []
        
        func fetchMedicineHistory(for medicineId: String) async throws -> [HistoryEntry] {
                if shouldFail { throw MockError.testFailure }
                return historyToReturn
        }
        
        func fetchAllHistory() async throws -> [HistoryEntry] {
                if shouldFail { throw MockError.testFailure }
                return historyToReturn
        }
        
        func addEntry(_ entry: HistoryEntry) async throws { }
        func addToHistory(action: String, medicineId: String, userEmail: String, details: String) async { }
}
