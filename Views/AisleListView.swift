//
//  AisleListView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

import SwiftUI

struct AisleListView: View {
        
        //MARK: Dépendances
        @Environment(MedicineStockViewModel.self) private var viewModel
        @Environment(SessionStore.self) private var sessionStore
        
        //MARK: Body
        var body: some View {
                NavigationStack { // Modernisation : NavigationStack au lieu de NavigationView
                        List {
                                // Utilisation de la propriété calculée du ViewModel
                                ForEach(viewModel.aisles, id: \.self) { aisle in
                                        NavigationLink(destination: MedicineListView(aisle: aisle)) {
                                                Text(aisle)
                                                        .font(.body)
                                        }
                                }
                        }
                        .navigationTitle("Rayons")
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                                // Utilise l'ID de l'utilisateur connecté pour l'historique
                                                if let userId = sessionStore.session?.id {
                                                        Task { await viewModel.addRandomMedicine(userId: userId) }
                                                }
                                        }) {
                                                Image(systemName: "plus")
                                        }
                                }
                        }
                        .task {
                                // Chargement asynchrone conforme au Green Code
                                await viewModel.fetchMedicines()
                        }
                }
        }
}

#Preview {
        AisleListView()
}
