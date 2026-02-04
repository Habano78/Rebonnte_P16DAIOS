//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct AllMedicinesView: View {
        
        //MARK: Dependences
        @Environment(DIContainer.self) private var di
        
        //MARK: Properties
        @State private var filterText: String = ""
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        List {
                                TextField("Rechercher un médicament...", text: $filterText)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.vertical, 5)
                                
                                ForEach(filteredMedicines) { medicine in
                                        NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                                                VStack(alignment: .leading) {
                                                        Text(medicine.name).font(.headline)
                                                        Text("Stock: \(medicine.stock)").font(.subheadline)
                                                }
                                        }
                                }
                        }
                        .navigationTitle("Inventaire complet")
                        .toolbar {
                                Button(action: {
                                        if let email = di.sessionStore.session?.email {
                                                Task { await di.medicineViewModel.addRandomMedicine(userId: email) }
                                        }
                                }) {
                                        Image(systemName: "plus")
                                }
                        }
                }
        }
        
        private var filteredMedicines: [Medicine] {
                if filterText.isEmpty { return di.medicineViewModel.medicines }
                return di.medicineViewModel.medicines.filter { $0.name.localizedCaseInsensitiveContains(filterText) }
        }
}

#Preview {
        AllMedicinesView()
}
