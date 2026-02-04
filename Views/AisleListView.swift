//
//  AisleListView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

import SwiftUI

struct AisleListView: View {
        
        //MARK: Dépendance
        @Environment(DIContainer.self) private var di
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        List {
                                ForEach(di.medicineViewModel.aisles, id: \.self) { aisle in
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
                                                if let userId = di.sessionStore.session?.id {
                                                        Task { await di.medicineViewModel.addRandomMedicine(userId: userId) }
                                                }
                                        }) {
                                                Image(systemName: "plus")
                                        }
                                }
                        }
                        .task {
                                await di.medicineViewModel.fetchMedicines()
                        }
                }
        }
}

#Preview {
        AisleListView()
}
