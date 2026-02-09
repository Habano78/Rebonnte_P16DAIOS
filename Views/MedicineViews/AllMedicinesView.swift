//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct AllMedicinesView: View {
        
        // MARK: - Dependencies
        @Environment(DIContainer.self) private var di
        
        // MARK: - Properties
        @State private var filterText: String = ""
        @State private var isShowingAddSheet = false
        
        private var currentUserId: String {
                di.sessionStore.session?.id ?? ""
        }
        
        // MARK: - Logic
        
        /// Combine les données du serveur (déjà triées/filtrées par catégorie)
        /// avec une recherche textuelle locale pour la réactivité.
        private var displayedMedicines: [Medicine] {
                if filterText.isEmpty {
                        return di.medicineViewModel.medicines
                } else {
                        return di.medicineViewModel.medicines.filter { medicine in
                                medicine.name.localizedCaseInsensitiveContains(filterText) ||
                                medicine.brand.localizedCaseInsensitiveContains(filterText)
                        }
                }
        }
        
        // MARK: - Body
        var body: some View {
                NavigationStack {
                        VStack(spacing: 0) {
                                
                                CategoryFilterView()
                                
                                List {
                                        ForEach(displayedMedicines) { medicine in
                                                NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                                                        VStack(alignment: .leading) {
                                                                Text(medicine.name)
                                                                        .font(.headline)
                                                                
                                                                Text("Stock : \(medicine.stock)")
                                                                        .font(.subheadline)
                                                                        .foregroundColor(medicine.isLowStock ? .red : .secondary)
                                                        }
                                                        // Accessibilité
                                                        .accessibilityElement(children: .combine)
                                                        .accessibilityLabel("\(medicine.name)")
                                                        .accessibilityValue(medicine.isLowStock ? "Stock critique : \(medicine.stock)" : "\(medicine.stock)")
                                                }
                                                // 🚀 Lazy Loading : Détection de la fin de liste
                                                .onAppear {
                                                        if medicine.id == di.medicineViewModel.medicines.last?.id && filterText.isEmpty {
                                                                Task {
                                                                        await di.medicineViewModel.loadMoreMedicines(userId: currentUserId)
                                                                }
                                                        }
                                                }
                                        }
                                        
                                        // Indicateur de chargement
                                        if di.medicineViewModel.isLoadingMore {
                                                HStack {
                                                        Spacer()
                                                        ProgressView("Chargement de la suite...")
                                                                .progressViewStyle(.circular)
                                                                .padding()
                                                        Spacer()
                                                }
                                        }
                                }
                                .listStyle(.plain)
                        }
                        .navigationTitle("Inventaire complet")
                        .searchable(text: $filterText, prompt: "Rechercher par nom (local)...")
                        
                        // MARK: - Toolbar
                        .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                        Menu {
                                                ForEach(SortOption.allCases) { option in
                                                        Button {
                                                                Task {
                                                                        await di.medicineViewModel.applySort(option, userId: currentUserId)
                                                                }
                                                        } label: {
                                                                HStack {
                                                                        Text(option.displayName)
                                                                        if di.medicineViewModel.sortOption == option {
                                                                                Image(systemName: "checkmark")
                                                                        }
                                                                }
                                                        }
                                                }
                                        } label: {
                                                Label("Trier", systemImage: "arrow.up.arrow.down.circle")
                                        }
                                }
                                
                                // Bouton Ajouter
                                ToolbarItem(placement: .primaryAction) {
                                        Button(action: { isShowingAddSheet = true }) {
                                                Image(systemName: "plus")
                                        }
                                }
                        }
                        .sheet(isPresented: $isShowingAddSheet) {
                                AddMedicineView()
                        }
                        .task {
                                if di.medicineViewModel.medicines.isEmpty && !currentUserId.isEmpty {
                                        await di.medicineViewModel.fetchMedicines(userId: currentUserId)
                                }
                        }
                }
        }
}
