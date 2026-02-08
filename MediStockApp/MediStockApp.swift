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
                        FirebaseApp.configure() }
                
                _container = State(wrappedValue: DIContainer())
                
                //TODO: placer dans une view
                requestNotificationPermission()
        }
        
        var body: some Scene {
                WindowGroup {
                        RootView()
                                .environment(container)
                                .onAppear {
                                                container.sessionStore.listen()
                                            }
                }
        }
        
        func requestNotificationPermission() {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if granted {
                                print("Permission Notifications accordée !")
                        } else if let error = error {
                                print("Erreur Permission : \(error.localizedDescription)")
                        }
                }
        }
}
