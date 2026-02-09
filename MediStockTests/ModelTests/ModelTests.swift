//
//  ModelTests.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Testing
import Foundation
@testable import MediStock

@Suite("Tests des Modèles de Données")
struct ModelTests {
    
    // On définit un ID utilisateur fictif pour les tests
    let testUserId = "user_test_123"
    
    // MARK: Stock
    @Test("Vérification du seuil d'alerte de stock (isLowStock)")
    func testLowStockLogic() {
        // --- GIVEN ---
        let threshold = 5
        
        // --- THEN ---
        /// Cas 1 : Stock sain
        let healthyMed = Medicine(
            id: "1",
            userId: testUserId,
            name: "A",
            brand: "B",
            stock: 10,
            aisle: "A1",
            alertThreshold: threshold,
            category: .other
        )
        #expect(healthyMed.isLowStock == false)
        
        /// Cas 2 : Stock au seuil limite
        let limitMed = Medicine(
            id: "2",
            userId: testUserId,
            name: "B",
            brand: "B",
            stock: 5,
            aisle: "A1",
            alertThreshold: threshold,
            category: .other
        )
        #expect(limitMed.isLowStock == true)
        
        /// Cas 3 : Stock critique
        let criticalMed = Medicine(
            id: "3",
            userId: testUserId,
            name: "C",
            brand: "B",
            stock: 2,
            aisle: "A1",
            alertThreshold: threshold,
            category: .other
        )
        #expect(criticalMed.isLowStock == true)
    }
    
    // MARK: Catégories
    @Test("Vérification des catégories et de leur identité")
    func medicineCategoryProperties() {
        let category = MedicineCategory.antibiotic
        #expect(category.id == "Antibiotique")
        #expect(MedicineCategory.allCases.count == 7)
    }
    
    // MARK: - Péremption
    @Test("Périmé si la date est passée")
    func testIsExpiredWithPastDate() {
        let yesterday = Date().addingTimeInterval(-86400)
        
        // ✅ CORRECTION : Ajout de userId
        let medicine = Medicine(
            id: "1",
            userId: testUserId,
            name: "Test",
            brand: "B",
            stock: 10,
            aisle: "A1",
            alertThreshold: 5,
            category: .other,
            expirationDate: yesterday
        )
        #expect(medicine.isExpired == true)
    }
    
    @Test("Non périmé si la date est future")
    func testIsExpiredWithFutureDate() {
        let tomorrow = Date().addingTimeInterval(86400)
        
        // ✅ CORRECTION : Ajout de userId
        let medicine = Medicine(
            id: "2",
            userId: testUserId,
            name: "Test",
            brand: "B",
            stock: 10,
            aisle: "A1",
            alertThreshold: 5,
            category: .other,
            expirationDate: tomorrow
        )
        #expect(medicine.isExpired == false)
    }
    
    @Test("Non périmé si aucune date n'est fournie")
    func testIsExpiredWithNoDate() {

        let medicine = Medicine(
            id: "3",
            userId: testUserId,
            name: "Test",
            brand: "B",
            stock: 10,
            aisle: "A1",
            alertThreshold: 5,
            category: .other,
            expirationDate: nil
        )
        #expect(medicine.isExpired == false)
    }
}
