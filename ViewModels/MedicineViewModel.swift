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
        
        // MARK: - Data State
        var medicines: [Medicine] = []
        var aisles: [String] = []
        var history: [HistoryEntry] = []
        
        // MARK: - UI State
        var isLoading = false
        var isLoadingMore = false
        var errorMessage: String? = nil
        
        // MARK: - Filter & Sort State
        var selectedCategory: MedicineCategory? = nil
        var sortOption: SortOption = .name
        
        // MARK: - Pagination State (Abstraction)
        var lastCursor: Any? = nil
        var canLoadMore = true
        private let pageSize = 20
        
        // MARK: - Initialization
        init(medicineService: any MedicineServiceProtocol,
             historyService: any HistoryServiceProtocol,
             authService: any AuthServiceProtocol) {
                self.medicineService = medicineService
                self.historyService = historyService
                self.authService = authService
        }
        
        // MARK: - Fetching Logic
        
        func fetchMedicines(userId: String) async {
                isLoading = true
                errorMessage = nil
                lastCursor = nil
                canLoadMore = true
                
                do {
                        let result = try await medicineService.fetchMedicines(
                                userId: userId,
                                category: selectedCategory,
                                sortBy: sortOption,
                                descending: false,
                                limit: pageSize,
                                lastCursor: nil
                        )
                        
                        self.medicines = result.medicines
                        self.lastCursor = result.lastCursor
                        self.canLoadMore = result.medicines.count == pageSize
                        
                        updateAisles()
                        
                } catch {
                        print("Erreur fetch: \(error.localizedDescription)")
                        self.errorMessage = "Impossible de charger les médicaments."
                }
                
                isLoading = false
        }
        
        func loadMoreMedicines(userId: String) async {
                guard !isLoading, !isLoadingMore, canLoadMore, let cursor = lastCursor else { return }
                
                isLoadingMore = true
                
                do {
                        let result = try await medicineService.fetchMedicines(
                                userId: userId,
                                category: selectedCategory,
                                sortBy: sortOption,
                                descending: false,
                                limit: pageSize,
                                lastCursor: cursor
                        )
                        
                        self.medicines.append(contentsOf: result.medicines)
                        self.lastCursor = result.lastCursor
                        self.canLoadMore = result.medicines.count == pageSize
                        
                        updateAisles()
                        
                } catch {
                        print("Erreur pagination: \(error.localizedDescription)")
                        self.errorMessage = "Erreur lors du chargement de la suite."
                }
                
                isLoadingMore = false
        }
        
        private func updateAisles() {
                self.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
        }
        
        // MARK: - Sorting & Filtering Helpers
        
        func applySort(_ option: SortOption, userId: String) async {
                self.sortOption = option
                await fetchMedicines(userId: userId)
        }
        
        func applyCategoryFilter(_ category: MedicineCategory?, userId: String) async {
                self.selectedCategory = category
                await fetchMedicines(userId: userId)
        }
        
        // MARK: - Optimistic Updates
        
        func addMedicine(_ medicine: Medicine, userId: String) async {
                // Optimistic Update : Ajout local
                self.medicines.append(medicine)
                updateAisles()
                
                do {
                        try await medicineService.saveMedicine(medicine)
                        
                        // Historique
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
                        self.errorMessage = "Erreur lors de l'ajout."
                        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
                                medicines.remove(at: index)
                                updateAisles()
                        }
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
                        self.errorMessage = "Erreur mise à jour stock."
                }
        }
        
        func deleteMedicine(id: String, userEmail: String) async {
                
                guard let medicineToDelete = medicines.first(where: { $0.id == id }) else { return }
                let medicineName = medicineToDelete.name
                let medicineAisle = medicineToDelete.aisle
                
                if let index = medicines.firstIndex(where: { $0.id == id }) {
                        medicines.remove(at: index)
                        updateAisles()
                }
                
                do {
                        try await medicineService.deleteMedicine(id: id)
                        
                        let entry = HistoryEntry(
                                id: UUID().uuidString,
                                medicineId: id,
                                userEmail: userEmail,
                                action: "Suppression",
                                details: "Suppression définitive de \(medicineName) (Rayon \(medicineAisle))",
                                timestamp: Date()
                        )
                        try await historyService.addEntry(entry)
                        
                } catch {
                        self.errorMessage = "Erreur lors de la suppression."
                        self.medicines.append(medicineToDelete)
                        updateAisles()
                }
        }
        
        // Dans MedicineStockViewModel.swift
        
        func updateMedicine(_ medicine: Medicine, userEmail: String) async {
                guard let index = medicines.firstIndex(where: { $0.id == medicine.id }) else { return }
                
                let oldMedicine = medicines[index]
                
                self.medicines[index] = medicine
                updateAisles()
                
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
                        
                } catch {
                        self.errorMessage = "Erreur modification."
                        
                        self.medicines[index] = oldMedicine
                        updateAisles()
                }
        }
        
        // MARK: - History Logic
        
        func fetchMedicineHistory(for medicineId: String) async {
                errorMessage = nil
                do {
                        self.history = try await historyService.fetchMedicineHistory(for: medicineId)
                } catch {
                        self.errorMessage = "Impossible de récupérer l'historique."
                }
        }
        
        func fetchAllHistory() async {
                isLoading = true
                errorMessage = nil
                do {
                        self.history = try await historyService.fetchAllHistory()
                } catch {
                        self.errorMessage = "Erreur historique global."
                }
                isLoading = false
        }
}
