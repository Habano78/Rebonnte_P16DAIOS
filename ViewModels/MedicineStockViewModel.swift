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
final class MedicineStockViewModel {
        var medicines: [Medicine] = []
        var aisles: [String] = []
        var history: [HistoryEntry] = []
        var isLoading = false
        
        private let medicineService: any MedicineServiceProtocol
        private let historyService: any HistoryServiceProtocol
        private let authService: any AuthServiceProtocol
        
        init(medicineService: any MedicineServiceProtocol,
             historyService: any HistoryServiceProtocol,
             authService: any AuthServiceProtocol) {
                self.medicineService = medicineService
                self.historyService = historyService
                self.authService = authService
        }
        
        // MARK: - Intents
        
        /// Charge la liste complète des médicaments et calcule les rayons
        func fetchMedicines() async {
                isLoading = true
                do {
                        let fetched = try await medicineService.fetchMedicines()
                        self.medicines = fetched
                        // Calcul des rayons uniques et triés pour l'UI
                        self.aisles = Array(Set(fetched.map { $0.aisle })).sorted()
                } catch {
                        print("Erreur fetch: \(error.localizedDescription)")
                }
                isLoading = false
        }
        
        /// Ajoute un médicament aléatoire (Utile pour le test des rayons)
        func addRandomMedicine(userId: String) async {
                let newMedicine = Medicine(
                        id: UUID().uuidString,
                        name: "Médicament \(Int.random(in: 1...100))",
                        stock: Int.random(in: 1...50),
                        aisle: "Rayon \(Int.random(in: 1...10))"
                )
                
                do {
                        // 1. Sauvegarde du médicament
                        try await medicineService.saveMedicine(newMedicine)
                        
                        // 2. Création de l'entrée d'historique
                        let entry = HistoryEntry(
                                id: UUID().uuidString,
                                medicineId: newMedicine.id,
                                userEmail: userId, // On utilise l'ID ou l'email passé par la vue
                                action: "Ajout",
                                details: "Création automatique du médicament \(newMedicine.name)",
                                timestamp: Date()
                        )
                        try await historyService.addEntry(entry)
                        
                        // 3. Rafraîchissement local
                        await fetchMedicines()
                } catch {
                        print("Erreur ajout: \(error.localizedDescription)")
                }
        }
        
        /// Supprime un médicament
        func deleteMedicine(id: String) async {
                do {
                        try await medicineService.deleteMedicine(id: id)
                        await fetchMedicines()
                } catch {
                        print("Erreur suppression: \(error.localizedDescription)")
                }
        }
        
        // MARK: Actions de détail
        func fetchHistory(for medicineId: String) async {
            do {
                /// On récupère les entrées triées par le service
                self.history = try await historyService.fetchHistory(for: medicineId)
            } catch {
                print("Erreur historique : \(error.localizedDescription)")
            }
        }

        /// Met à jour un médicament et génère automatiquement une trace dans l'historique
        func updateMedicine(_ medicine: Medicine, userEmail: String) async {
            do {
                // 1. Mise à jour du stock ou des infos dans Firestore
                try await medicineService.saveMedicine(medicine)
                
                // 2. Création d'une entrée d'historique enrichie
                let entry = HistoryEntry(
                    id: UUID().uuidString,
                    medicineId: medicine.id,
                    userEmail: userEmail, // Email de l'opérateur connecté
                    action: "Modification",
                    details: "Mise à jour des informations pour \(medicine.name) (Stock actuel : \(medicine.stock))",
                    timestamp: Date()
                )
                
                // 3. Enregistrement de la trace
                try await historyService.addEntry(entry)
                
                // 4. Rafraîchissement des données locales pour l'UI
                await fetchMedicines()
                await fetchHistory(for: medicine.id)
                
            } catch {
                print("Erreur mise à jour : \(error.localizedDescription)")
            }
        }
}
