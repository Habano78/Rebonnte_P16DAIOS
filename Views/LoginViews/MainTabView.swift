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
                                .tabItem { Label("Rayons", systemImage: "square.grid.2x2") }
                        
                        AllMedicinesView()
                                .tabItem { Label("Médicaments", systemImage: "pill.fill") }
                        
                        HistoryView()
                                .tabItem { Label("Historique", systemImage: "clock.arrow.circlepath") }
                        
                        ProfileView()
                                .tabItem { Label("Compte", systemImage: "person.crop.circle") }
                }
        }
}
