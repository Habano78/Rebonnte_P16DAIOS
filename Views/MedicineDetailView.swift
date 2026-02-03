//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//
import SwiftUI

struct MedicineDetailView: View {
        
        //MARK: Dependences
        @Environment(MedicineStockViewModel.self) private var viewModel
        @Environment(SessionStore.self) private var sessionStore
        
        //MARK: Properties
        @State var medicine: Medicine
        
        //MARK: Body
        var body: some View {
                Form {
                        Section("Informations") {
                                TextField("Nom", text: $medicine.name)
                                Stepper("Stock : \(medicine.stock)", value: $medicine.stock)
                                TextField("Rayon", text: $medicine.aisle)
                        }
                        
                        Section {
                                Button("Enregistrer les modifications") {
                                        saveChanges()
                                }
                                .disabled(sessionStore.session == nil)
                        }
                        
                        Section("Historique des mouvements") {
                                ForEach(viewModel.history) { entry in
                                        VStack(alignment: .leading) {
                                                Text(entry.action).font(.subheadline).bold()
                                                Text("Par : \(entry.userEmail)").font(.caption)
                                                Text(entry.timestamp.formatted()).font(.caption2).foregroundColor(.secondary)
                                        }
                                }
                        }
                }
                .navigationTitle(medicine.name)
                .task {
                        // Chargement de l'historique spécifique au médicament
                        await viewModel.fetchHistory(for: medicine.id)
                }
        }
        
        //MARK: private
        private func saveChanges() {
                guard let userEmail = sessionStore.session?.email else { return }
                Task {
                        // Le ViewModel s'occupe de mettre à jour Firestore et l'historique
                        await viewModel.updateMedicine(medicine, userEmail: userEmail)
                }
        }
}
