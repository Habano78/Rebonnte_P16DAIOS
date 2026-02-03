//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI
import FirebaseCore

@main
struct MediStockApp: App {
    // On déclare le container sans l'initialiser immédiatement
    @State private var container: DIContainer
    
    init() {
        // 1. Configurer Firebase en priorité ABSOLUE
        FirebaseApp.configure()
        print("✅ [Debug] FirebaseApp.configure() a été appelé")
        
        // 2. Initialiser le State avec le wrapper '_' pour garantir l'ordre
        // Cela force le container à n'être créé qu'APRÈS la configuration Firebase
        self._container = State(initialValue: DIContainer())
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container.authViewModel)
                .environment(container.medicineViewModel)
                .environment(container.sessionStore)
        }
    }
}
