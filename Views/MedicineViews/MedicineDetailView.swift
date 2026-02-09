//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct MedicineDetailView: View {
        
        // MARK: Dependencies
        @Environment(DIContainer.self) private var di
        @Environment(\.dismiss) private var dismiss
        
        // MARK: Properties
        let medicine: Medicine
        
        // MARK: State
        @State private var isShowingEditSheet = false
        @State private var isShowingDeleteAlert = false
        
        // MARK: Body
        var body: some View {
                Form {
                        
                        // Section informations
                        Section("Informations") {
                                Text(medicine.name).font(.headline)
                                
                                if medicine.isExpired {
                                        HStack {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                Text("Produit périmé")
                                        }
                                        .foregroundColor(.red)
                                        .font(.callout).bold()
                                }
                                
                                DetailRow(label: "Stock", value: "\(medicine.stock)", isBold: true)
                                DetailRow(label: "Rayon", value: medicine.aisle)
                                
                                if let expiry = medicine.expirationDate {
                                        DateRow(label: "Péremption", date: expiry)
                                }
                                
                                DetailRow(label: "Marque", value: medicine.brand.isEmpty ? "Non spécifiée" : medicine.brand)
                                DetailRow(label: "Catégorie", value: medicine.category.rawValue)
                        }
                        
                        // Section Historique
                        Section("Historique des mouvements") {
                                if di.medicineViewModel.history.isEmpty {
                                        Text("Aucun mouvement enregistré.").foregroundColor(.secondary)
                                } else {
                                        ForEach(di.medicineViewModel.history) { entry in
                                                HistoryRow(entry: entry)
                                        }
                                }
                        }
                        
                        // Section Actions
                        Section {
                                Button(role: .destructive) {
                                        isShowingDeleteAlert = true
                                } label: {
                                        HStack {
                                                Spacer()
                                                Text("Supprimer le médicament")
                                                Spacer()
                                        }
                                        .accessibilityLabel("Supprimer \(medicine.name)")
                                }
                        }
                }
                
                // MARK: View Modifiers
                .navigationTitle(medicine.name)
                .toolbar {
                        Button("Modifier") {
                                isShowingEditSheet = true
                        }
                        .foregroundStyle(.blue)
                        .fontWeight(.medium)
                }
                
                // MARK: Alerts & Sheets
                .sheet(isPresented: $isShowingEditSheet) {
                        EditMedicineView(medicine: medicine)
                }
                .alert("Supprimer \(medicine.name) ?", isPresented: $isShowingDeleteAlert) {
                        Button("Annuler", role: .cancel) { }
                        
                        Button("Supprimer", role: .destructive) {
                                Task {
                                        let userEmail = di.sessionStore.userEmail ?? "Inconnu"
                                        
                                        await di.medicineViewModel.deleteMedicine(
                                                id: medicine.id ?? "",
                                                userEmail: userEmail
                                        )
                                        
                                        dismiss()
                                }
                        }
                } message: {
                        Text("Cette action est irréversible. L'événement sera enregistré dans l'historique.")
                }
                // MARK: Lifecycle
                .task {
                        await di.medicineViewModel.fetchMedicineHistory(for: medicine.id ?? "")
                }
        }
}

// MARK: Subviews
struct DetailRow: View {
        let label: String
        let value: String
        var isBold: Bool = false
        
        var body: some View {
                HStack {
                        Text(LocalizedStringKey(label))
                        Spacer()
                        Text(value)
                                .foregroundColor(.secondary)
                                .fontWeight(isBold ? .bold : .regular)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(LocalizedStringKey(label))
                .accessibilityValue(value)
        }
}

struct DateRow: View {
        let label: String
        let date: Date
        var style: Text.DateStyle = .date
        
        var body: some View {
                HStack {
                        Text(LocalizedStringKey(label))
                        Spacer()
                        Text(date, style: style)
                                .foregroundColor(.secondary)
                }
        }
}
