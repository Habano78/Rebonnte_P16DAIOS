//
//  EditMedicineView.swift
//  MediStock
//
//  Created by Perez William on 06/02/2026.
//

import SwiftUI

struct EditMedicineView: View {
        
        //MARK: Dependences 
        @Environment(DIContainer.self) private var di
        @Environment(\.dismiss) private var dismiss
        
        let medicine: Medicine
        
        // MARK: - States
        @State private var name: String
        @State private var brand: String
        @State private var category: MedicineCategory
        @State private var editedStock: Int
        @State private var alertThreshold: Int
        @State private var aisle: String
        
        // MARK: - Init
        init(medicine: Medicine) {
                self.medicine = medicine
                _name = State(initialValue: medicine.name)
                _brand = State(initialValue: medicine.brand)
                _category = State(initialValue: medicine.category)
                _editedStock = State(initialValue: medicine.stock)
                _alertThreshold = State(initialValue: medicine.alertThreshold)
                _aisle = State(initialValue: medicine.aisle)
        }
        
        var body: some View {
                NavigationStack {
                        Form {
                                Section("Informations Générales") {
                                        TextField("Nom", text: $name)
                                        TextField("Marque", text: $brand)
                                        Picker("Catégorie", selection: $category) {
                                                ForEach(MedicineCategory.allCases) { cat in
                                                        Text(cat.rawValue).tag(cat)
                                                }
                                        }
                                }
                                
                                Section("Gestion du Stock") {
                                        HStack {
                                                Text("Rayon")
                                                Spacer()
                                                TextField("Ex: 1", text: $aisle)
                                                        .multilineTextAlignment(.trailing)
                                                        .foregroundColor(.secondary)
                                        }
                                        
                                        Stepper("Stock actuel : \(editedStock)", value: $editedStock, in: 0...9999)
                                            .accessibilityLabel("Ajuster le stock")
                                            .accessibilityValue("\(editedStock) boîtes")
                                        
                                        Stepper("Seuil d'alerte : \(alertThreshold)", value: $alertThreshold, in: 0...100)
                                        
                                }
                        }
                        .navigationTitle("Modifier \(medicine.name)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") { dismiss() }
                                }
                                
                                ToolbarItem(placement: .confirmationAction) {
                                        Button("Enregistrer") {
                                                saveChanges()
                                        }
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                }
                        }
                }
        }
        
        private func saveChanges() {
                
                let updatedMedicine = Medicine(
                        id: medicine.id,
                        name: name,
                        brand: brand,
                        stock: editedStock,
                        aisle: aisle,
                        alertThreshold: alertThreshold,
                        category: category,
                        expirationDate: medicine.expirationDate
                )
                
                Task {
                        let userEmail = di.sessionStore.userEmail ?? "Inconnu"
                        await di.medicineViewModel.updateMedicine(updatedMedicine, userEmail: userEmail)
                        dismiss()
                }
        }
}
