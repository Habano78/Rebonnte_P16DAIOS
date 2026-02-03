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
        
        
        @State private var container: DIContainer
        
        init() {
                
                if FirebaseApp.app() == nil {
                        FirebaseApp.configure()
                }
                
                self.container = DIContainer()
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
