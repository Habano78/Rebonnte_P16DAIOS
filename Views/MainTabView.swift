//
//  MainTabView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct MainTabView: View {
        
        var body: some View {
                TabView {
                        AisleListView()
                                .tabItem {
                                        Label("Rayons", systemImage: "list.dash")
                                }
                        
                        AllMedicinesView()
                                .tabItem {
                                        Label("Médicaments", systemImage: "square.grid.2x2")
                                }
                }
        }
}

#Preview {
        MainTabView()
}
