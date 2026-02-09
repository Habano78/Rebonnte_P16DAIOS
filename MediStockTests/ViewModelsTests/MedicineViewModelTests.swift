//
//  MedicineViewModelTests.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Testing
import Foundation
@testable import MediStock

@Suite("Tests du MedicineViewModel")
@MainActor
struct MedicineViewModelTests {
        
        // Données de test
        let testUserId = "user_test_123"
        let testUserEmail = "test@medistock.com"
        
        // MARK: - Fetch Tests
        
        @Test("Vérifier que fetchMedicines met à jour la liste et les rayons")
        func testFetchMedicinesUpdatesState() async {
                // GIVEN
                let mockMedicines = [
                        Medicine(id: "1", userId: testUserId, name: "Doliprane", brand: "Sanofi", stock: 10, aisle: "Rayon A", alertThreshold: 5, category: .analgesic),
                        Medicine(id: "2", userId: testUserId, name: "Advil", brand: "Pfizer", stock: 20, aisle: "Rayon B", alertThreshold: 5, category: .analgesic)
                ]
                
                let mockService = MockMedicineService()
                mockService.medicinesToReturn = mockMedicines
                
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                // WHEN
                await vm.fetchMedicines(userId: testUserId)
                
                // THEN
                #expect(vm.medicines.count == 2)
                #expect(vm.medicines.first?.name == "Doliprane")
                #expect(vm.aisles == ["Rayon A", "Rayon B"])
                #expect(vm.isLoading == false)
        }
        
        @Test("Échec de fetchMedicines et gestion de l'état")
        func testFetchMedicinesFailure() async {
                // GIVEN
                let mockService = MockMedicineService()
                mockService.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                #expect(vm.medicines.isEmpty)
                
                // WHEN
                await vm.fetchMedicines(userId: testUserId)
                
                // THEN
                #expect(vm.medicines.isEmpty)
                #expect(vm.isLoading == false)
        }
        
        // MARK: - Add Tests
        
        @Test("Ajout réussi d'un médicament")
        func testAddMedicineSuccess() async {
                // GIVEN
                let mockService = MockMedicineService()
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let newMed = Medicine(id: "new_1", userId: testUserId, name: "Aspi", brand: "Teva", stock: 30, aisle: "A1", alertThreshold: 5, category: .other)
                
                // WHEN
                await vm.addMedicine(newMed, userId: testUserEmail)
                
                // THEN
                #expect(vm.medicines.count == 1)
                #expect(vm.medicines.first?.name == "Aspi")
                #expect(vm.aisles.contains("A1"))
        }
        
        @Test("Échec de l'ajout et retour en arrière (Rollback)")
        func testAddMedicineFailure() async {
                // GIVEN
                let mockService = MockMedicineService()
                mockService.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let newMed = Medicine(id: "fail_1", userId: testUserId, name: "Erreur", brand: "B", stock: 10, aisle: "A1", alertThreshold: 5, category: .other)
                
                // WHEN
                await vm.addMedicine(newMed, userId: testUserEmail)
                
                // THEN
                #expect(vm.medicines.isEmpty, "La liste devrait être vide après l'échec de la sauvegarde.")
        }
        
        // MARK: Update Stock Tests
        
        @Test("Mise à jour du stock Réussite")
        func testUpdateStockSuccess() async {
                // GIVEN
                let mockService = MockMedicineService()
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let medicineId = "med_001"
                vm.medicines = [
                        Medicine(id: medicineId, userId: testUserId, name: "Doliprane", brand: "Sanofi", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                ]
                
                // WHEN
                await vm.updateStock(medicineId: medicineId, newStock: 25, userId: testUserEmail)
                
                // THEN
                #expect(vm.medicines[0].stock == 25)
        }
        
        @Test("Échec mise à jour Stock et retour au stock initial")
        func testUpdateStockRollback() async {
                // GIVEN
                let mockService = MockMedicineService()
                mockService.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let initialStock = 10
                let medicineId = "med_001"
                vm.medicines = [
                        Medicine(id: medicineId, userId: testUserId, name: "Doliprane", brand: "Sanofi", stock: initialStock, aisle: "A1", alertThreshold: 5, category: .analgesic)
                ]
                
                // WHEN
                await vm.updateStock(medicineId: medicineId, newStock: 99, userId: testUserEmail)
                
                // THEN
                #expect(vm.medicines[0].stock == initialStock, "Le stock aurait dû être remis à \(initialStock) après l'erreur.")
        }
        
        // MARK: Update Medicine Tests
        
        @Test("Réussite de la mise à jour complète d'un médicament")
        func testUpdateMedicineSuccess() async {
                // GIVEN
                let mockService = MockMedicineService()
                let vm = MedicineViewModel(medicineService: mockService, historyService: MockHistoryService(), authService: MockAuthService())
                
                let initialMed = Medicine(id: "1", userId: testUserId, name: "Doliprane", brand: "S", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                vm.medicines = [initialMed]
                
                let updatedMed = Medicine(id: "1", userId: testUserId, name: "Doliprane Forte", brand: "S", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                
                // WHEN
                await vm.updateMedicine(updatedMed, userEmail: testUserEmail)
                
                // THEN
                #expect(vm.medicines.first?.name == "Doliprane Forte")
        }
        
        @Test("Échec de la mise à jour et rollback des données")
        func testUpdateMedicineRollback() async {
                // GIVEN
                let mockService = MockMedicineService()
                mockService.shouldFail = true
                
                let vm = MedicineViewModel(medicineService: mockService, historyService: MockHistoryService(), authService: MockAuthService())
                
                let initialMed = Medicine(id: "1", userId: testUserId, name: "Doliprane", brand: "S", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                vm.medicines = [initialMed]
                
                let updatedMed = Medicine(id: "1", userId: testUserId, name: "Modifié", brand: "S", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                
                // WHEN
                await vm.updateMedicine(updatedMed, userEmail: testUserEmail)
                
                // THEN
                #expect(vm.medicines.first?.name == "Doliprane", "Le nom aurait dû revenir à 'Doliprane' après l'échec.")
                
        }
        
        // MARK: - Delete Tests
        
        @Test("Réussite de la suppression d'un médicament")
        func testDeleteMedicineSuccess() async {
                // GIVEN
                let mockService = MockMedicineService()
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let medicineId = "to_delete"
                let medicine = Medicine(id: medicineId, userId: testUserId, name: "Aspégic", brand: "A", stock: 10, aisle: "A1", alertThreshold: 5, category: .analgesic)
                vm.medicines = [medicine]
                
                // WHEN
                await vm.deleteMedicine(id: medicineId, userEmail: testUserEmail)
                
                // THEN
                #expect(vm.medicines.isEmpty)
        }
        
        @Test("Échec de suppression et restauration du médicament (Rollback)")
        func testDeleteMedicineFailure() async {
                // GIVEN
                let mockService = MockMedicineService()
                mockService.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: mockService,
                        historyService: MockHistoryService(),
                        authService: MockAuthService()
                )
                
                let medicineId = "fail_delete"
                let medicine = Medicine(id: medicineId, userId: testUserId, name: "Garder Moi", brand: "B", stock: 5, aisle: "A1", alertThreshold: 2, category: .other)
                vm.medicines = [medicine]
                
                // WHEN
                await vm.deleteMedicine(id: medicineId, userEmail: testUserEmail)
                
                // THEN
                #expect(vm.medicines.count == 1, "Le médicament aurait dû être restauré dans la liste après l'échec.")
                #expect(vm.medicines.first?.id == medicineId)
        }
        
        // MARK: - History Service Tests
        
        @Test("Vérification du message d'erreur lors du fetch global")
        func testFetchAllHistoryFailureSetsErrorMessage() async {
                // GIVEN
                let mockHistory = MockHistoryService()
                mockHistory.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: MockMedicineService(),
                        historyService: mockHistory,
                        authService: MockAuthService()
                )
                
                // WHEN
                await vm.fetchAllHistory()
                
                // THEN
                #expect(vm.errorMessage == "Erreur historique global.")
                #expect(vm.isLoading == false)
        }
        
        @Test("Vérification du message d'erreur lors du fetch spécifique")
        func testFetchMedicineHistoryFailureSetsErrorMessage() async {
                // GIVEN
                let mockHistory = MockHistoryService()
                mockHistory.shouldFail = true
                
                let vm = MedicineViewModel(
                        medicineService: MockMedicineService(),
                        historyService: mockHistory,
                        authService: MockAuthService()
                )
                
                // WHEN
                await vm.fetchMedicineHistory(for: "any_id")
                
                // THEN
                #expect(vm.errorMessage == "Impossible de récupérer l'historique.")
        }
}
