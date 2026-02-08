//
//  MedicineListView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct MedicineListView: View {
        
        //MARK: Dependence
        @Environment(DIContainer.self) private var di
        @State private var isShowingAddSheet = false
        
        //MARK: Properties
        let aisle: String
        
        // MARK: Computed Properties
        private var sortedAisleMedicines: [Medicine] {
                di.medicineViewModel.medicines
                        .filter { $0.aisle == aisle }
                        .sorted {
                                if $0.isLowStock != $1.isLowStock {
                                        return $0.isLowStock && !$1.isLowStock
                                }
                                return $0.name < $1.name
                        }
        }
        
        
        //MARK: Body
        var body: some View {
                List {
                        ForEach(sortedAisleMedicines) { medicine in
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
                .navigationTitle("Rayon: \(aisle)")
                .toolbar {
                        Button {
                                isShowingAddSheet = true
                        } label: {
                                Image(systemName: "plus")
                        }
                }
                .sheet(isPresented: $isShowingAddSheet) {
                        AddMedicineView(initialAisle: aisle)
                }
        }
}
