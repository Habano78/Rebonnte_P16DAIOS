//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//
import SwiftUI

struct MedicineDetailView: View {
        
        //MARK: Dependences
        @Environment(DIContainer.self) private var di
        
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
                                .disabled(di.sessionStore.session == nil)
                        }
                        
                        Section("Historique des mouvements") {
                                ForEach(di.medicineViewModel.history) { entry in
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
                        await di.medicineViewModel.fetchHistory(for: medicine.id)
                }
        }
        
        //MARK: private
        private func saveChanges() {
                guard let userEmail = di.sessionStore.session?.email else { return }
                Task {
                        // Le ViewModel s'occupe de mettre à jour Firestore et l'historique
                        await di.medicineViewModel.updateMedicine(medicine, userEmail: userEmail)
                }
        }
}
