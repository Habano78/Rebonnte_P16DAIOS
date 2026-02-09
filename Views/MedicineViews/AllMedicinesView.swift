//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct AllMedicinesView: View {
        // MARK: Dependences
        @Environment(DIContainer.self) private var di
        
        // MARK: Properties
        @State private var filterText: String = ""
        @State private var isShowingAddSheet = false
        
        //MARK: Logique de filtrage
        private var filteredMedicines: [Medicine] {
                let baseList: [Medicine]
                if filterText.isEmpty {
                        baseList = di.medicineViewModel.medicines
                } else {
                        baseList = di.medicineViewModel.medicines.filter { medicine in
                                medicine.name.localizedCaseInsensitiveContains(filterText) ||
                                medicine.brand.localizedCaseInsensitiveContains(filterText)
                        }
                }
                return baseList.sorted {
                        if $0.isLowStock != $1.isLowStock {
                                return $0.isLowStock && !$1.isLowStock
                        }
                        return $0.name < $1.name
                }
        }
        
        // MARK: Body
        var body: some View {
                NavigationStack {
                        List {
                                
                                ForEach(filteredMedicines) { medicine in
                                        NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                                                VStack(alignment: .leading) {
                                                        Text(medicine.name)
                                                                .font(.headline)
                                                        
                                                        Text("Stock : \(medicine.stock)")
                                                                .font(.subheadline)
                                                                .foregroundColor(medicine.isLowStock ? .red : .secondary)
                                                }
                                                // MARK: Accessibilité
                                                .accessibilityElement(children: .combine)
                                                .accessibilityLabel("\(medicine.name)")
                                                .accessibilityValue(medicine.isLowStock ? "Stock critique : \(medicine.stock) unités" : "\(medicine.stock) en stock")
                                        }
                                }
                        }
                        .navigationTitle("Inventaire complet")
                        .searchable(text: $filterText, prompt: "Nom ou marque...")
                        .toolbar {
                                Button(action: { isShowingAddSheet = true }) {
                                        Image(systemName: "plus")
                                }
                        }
                        .sheet(isPresented: $isShowingAddSheet) {
                                AddMedicineView()
                        }
                        .task {
                                await di.medicineViewModel.fetchMedicines()
                        }
                }
        }
}
