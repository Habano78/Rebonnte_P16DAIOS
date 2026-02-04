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
        
        //MARK: Propertie
        let aisle: String
        
        //MARK: Body
        var body: some View {
                List {
                        
                        ForEach(di.medicineViewModel.medicines.filter { $0.aisle == aisle }) { medicine in
                                NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                                        VStack(alignment: .leading) {
                                                Text(medicine.name)
                                                        .font(.headline)
                                                Text("Stock : \(medicine.stock)")
                                                        .font(.subheadline)
                                                        .foregroundColor(medicine.stock < 5 ? .red : .secondary)
                                        }
                                }
                        }
                }
                .navigationTitle(aisle)
        }
}

#Preview {
        MedicineListView(aisle: "Aisle 1")
}
