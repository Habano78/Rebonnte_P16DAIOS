//
//  MedicineStockViewModel.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MedicineViewModel {
        
        // MARK: - Dependencies
        private let medicineService: any MedicineServiceProtocol
        private let historyService: any HistoryServiceProtocol
        private let authService: any AuthServiceProtocol
        
        // MARK: - State
        var medicines: [Medicine] = []
        var aisles: [String] = []
        var history: [HistoryEntry] = []
        var isLoading = false
        var errorMessage: String? = nil
        
        // MARK: - Initialization
        init(medicineService: any MedicineServiceProtocol,
             historyService: any HistoryServiceProtocol,
             authService: any AuthServiceProtocol) {
                self.medicineService = medicineService
                self.historyService = historyService
                self.authService = authService
        }
        
        // MARK: Fetching Logic
        
        func fetchMedicines() async {
                isLoading = true
                do {
                        let fetched = try await medicineService.fetchMedicines()
                        self.medicines = fetched
                        self.aisles = Array(Set(fetched.map { $0.aisle })).sorted()
                } catch {
                        print("Erreur fetch: \(error.localizedDescription)")
                }
                isLoading = false
        }
        
        func addMedicine(_ medicine: Medicine, userId: String) async {
                let oldMedicines = self.medicines
                let oldAisles = self.aisles
              
                self.medicines.append(medicine)
                self.aisles = Array(Set(self.medicines.map { $0.aisle })).sorted()
                
                do {
                        try await medicineService.saveMedicine(medicine)
                        
                        let entry = HistoryEntry(
                                id: UUID().uuidString,
                                medicineId: medicine.id ?? "",
                                userEmail: userId,
                                action: HistoryAction.added.rawValue,
                                details: "Ajout de \(medicine.name) au rayon \(medicine.aisle)",
                                timestamp: Date()
                        )
                        try await historyService.addEntry(entry)
                } catch {
                        self.medicines = oldMedicines
                        self.aisles = oldAisles
                }
        }
        
        func updateStock(medicineId: String, newStock: Int, userId: String) async {
                guard let index = medicines.firstIndex(where: { $0.id == medicineId }) else { return }
                let oldStock = medicines[index].stock
                guard oldStock != newStock else { return }
                
                medicines[index].stock = newStock
                
                do {
                        try await medicineService.updateStock(medicineId: medicineId, newStock: newStock)
                        await historyService.addToHistory(
                                action: HistoryAction.stockUpdate.rawValue,
                                medicineId: medicineId,
                                userEmail: userId,
                                details: "Stock modifié de \(oldStock) à \(newStock)"
                        )
                } catch {
                        medicines[index].stock = oldStock
                }
        }
        
        func deleteMedicine(id: String) async {
                let oldMedicines = self.medicines
                let oldAisles = self.aisles
                
                self.medicines.removeAll { $0.id == id }
                self.aisles = Array(Set(self.medicines.map { $0.aisle })).sorted()
                
                do {
                        try await medicineService.deleteMedicine(id: id)
                } catch {
                        self.medicines = oldMedicines
                        self.aisles = oldAisles
                }
        }
        
        func updateMedicine(_ medicine: Medicine, userEmail: String) async {
                let oldMedicines = self.medicines
                if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
                        self.medicines[index] = medicine
                }
                
                do {
                        try await medicineService.saveMedicine(medicine)
                        let entry = HistoryEntry(
                                id: UUID().uuidString,
                                medicineId: medicine.id ?? "",
                                userEmail: userEmail,
                                action: "Modification",
                                details: "Mise à jour de \(medicine.name)",
                                timestamp: Date()
                        )
                        try await historyService.addEntry(entry)
                        await fetchMedicines()
                } catch {
                        self.medicines = oldMedicines
                }
        }
        
        // MARK: History
        
        func fetchMedicineHistory(for medicineId: String) async {
                errorMessage = nil
                do {
                        self.history = try await historyService.fetchMedicineHistory(for: medicineId)
                } catch {
                        self.errorMessage = "Impossible de récupérer l'historique spécifique."
                }
        }
        
        
        func fetchAllHistory() async {
                isLoading = true
                errorMessage = nil
                do {
                        self.history = try await historyService.fetchAllHistory()
                } catch {
                        self.errorMessage = "Erreur lors du chargement de l'historique global."
                }
                isLoading = false
        }
}
