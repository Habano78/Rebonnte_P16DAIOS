//
//  MedicineServiceProtocol.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation

protocol MedicineServiceProtocol {
    func fetchMedicines() async throws -> [Medicine]
    func fetchAisles() async throws -> [String]
    func updateMedicine(_ medicine: Medicine, user: String) async throws
    func deleteMedicine(id: String) async throws
    func addHistory(entry: HistoryEntry) async throws
}

class MedicieService : MedicineServiceProtocol {
        
}
