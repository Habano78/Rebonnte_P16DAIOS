//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Perez William on 05/02/2026.
//
import SwiftUI

struct AddMedicineView: View {
        @Environment(DIContainer.self) private var di
        @Environment(\.dismiss) private var dismiss
        
        // Propriétés d'état
        @State private var name = ""
        @State private var brand = ""
        @State private var category: MedicineCategory = .other
        @State private var stock = 0
        @State private var alertThreshold = 5
        @State private var aisle: String
        @State private var hasExpirationDate = false
        @State private var expirationDate = Date()
        
        init(initialAisle: String? = nil) {
                _aisle = State(initialValue: initialAisle ?? "")
        }
        
        var body: some View {
                NavigationStack {
                        Form {
                                Section("Informations Générales") {
                                        TextField("Nom du médicament", text: $name)
                                        TextField("Marque / Laboratoire", text: $brand)
                                        
                                        Picker("Catégorie", selection: $category) {
                                                ForEach(MedicineCategory.allCases) { cat in
                                                        Text(cat.rawValue).tag(cat)
                                                }
                                        }
                                        .pickerStyle(.menu)
                                }
                                
                                Section("Stock et Emplacement") {
                                        Stepper("Quantité en stock : \(stock)", value: $stock, in: 0...999)
                                        Stepper("Seuil d'alerte : \(alertThreshold)", value: $alertThreshold, in: 0...100)
                                        
                                        // Ajout d'une étiquette pour le rayon
                                        HStack {
                                                Text("Rayon")
                                                Spacer()
                                                TextField("Ex: A1", text: $aisle)
                                                        .multilineTextAlignment(.trailing)
                                                        .foregroundColor(.secondary)
                                        }
                                }
                                
                                Section("Péremption") {
                                        Toggle("Date de péremption", isOn: $hasExpirationDate.animation())
                                        
                                        // Affichage conditionnel fluide
                                        if hasExpirationDate {
                                                DatePicker("Choisir une date", selection: $expirationDate, displayedComponents: .date)
                                                        .datePickerStyle(.graphical)
                                        }
                                }
                        }
                        .navigationTitle("Nouveau Produit")
                        .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") { dismiss() }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                        Button("Enregistrer") { save() }
                                                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || aisle.isEmpty)
                                }
                        }
                }
        }
        
        private func save() {
                
                let currentUserId = di.sessionStore.session?.id ?? ""
                guard !currentUserId.isEmpty else { return }
                
                let newMedicine = Medicine(
                        id: UUID().uuidString,
                        userId: currentUserId,
                        name: name,
                        brand: brand,
                        stock: stock,
                        aisle: aisle,
                        alertThreshold: alertThreshold,
                        category: category,
                        expirationDate: hasExpirationDate ? expirationDate : nil
                )
                
                Task {
                        let userEmail = di.sessionStore.userEmail ?? "Inconnu"
                        await di.medicineViewModel.addMedicine(newMedicine, userId: userEmail)
                        dismiss()
                }
        }
}
