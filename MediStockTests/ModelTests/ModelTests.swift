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
        
        // MARK: Stock
        @Test("Vérification du seuil d'alerte de stock (isLowStock)")
        func testLowStockLogic() {
                // GIVEN
                let threshold = 5
                
                // THEN
                ///  Stock ok
                let healthyMed = Medicine(id: "1", name: "A", brand: "B", stock: 10, aisle: "A1", alertThreshold: threshold, category: .other)
                #expect(healthyMed.isLowStock == false)
                
                /// Stock au seuil limite
                let limitMed = Medicine(id: "2", name: "B", brand: "B", stock: 5, aisle: "A1", alertThreshold: threshold, category: .other)
                #expect(limitMed.isLowStock == true)
                
                ///  Stock critique
                let criticalMed = Medicine(id: "3", name: "C", brand: "B", stock: 2, aisle: "A1", alertThreshold: threshold, category: .other)
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
                let medicine = Medicine(id: "1", name: "Test", brand: "B", stock: 10, aisle: "A1", alertThreshold: 5, category: .other, expirationDate: yesterday)
                #expect(medicine.isExpired == true)
        }
        
        @Test("Non périmé si la date est future")
        func testIsExpiredWithFutureDate() {
                let tomorrow = Date().addingTimeInterval(86400)
                let medicine = Medicine(id: "2", name: "Test", brand: "B", stock: 10, aisle: "A1", alertThreshold: 5, category: .other, expirationDate: tomorrow)
                #expect(medicine.isExpired == false)
        }
        
        @Test("Non périmé si aucune date n'est fournie")
        func testIsExpiredWithNoDate() {
                let medicine = Medicine(id: "3", name: "Test", brand: "B", stock: 10, aisle: "A1", alertThreshold: 5, category: .other, expirationDate: nil)
                #expect(medicine.isExpired == false)
        }
}
