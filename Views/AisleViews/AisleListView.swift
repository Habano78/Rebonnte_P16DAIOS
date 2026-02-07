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
        
        //MARK: Property
        @State private var isShowingAddSheet = false
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        List {
                                ForEach(di.medicineViewModel.aisles, id: \.self) { aisle in
                                        NavigationLink(destination: MedicineListView(aisle: aisle)) {
                                                Text("Rayon : \(aisle)")
                                                        .font(.body)
                                        }
                                }
                        }
                        .navigationTitle("Rayons")
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        
                                        Button(action: {
                                                isShowingAddSheet=true
                                        }) {
                                                Image(systemName: "plus")
                                        }
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
