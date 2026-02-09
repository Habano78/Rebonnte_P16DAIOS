//
//  RootView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI
import UserNotifications

struct RootView: View {
        
        //MARK: Dependence
        @Environment(DIContainer.self) private var di
        
        //MARK: Body
        var body: some View {
                Group {
                        if di.sessionStore.isLoading {
                                LoadingSplashView()
                                        .transition(.opacity)
                                
                        } else if di.sessionStore.session != nil {
                                MainTabView()
                                        .transition(.opacity)
                                        .task {
                                                await requestNotificationPermission()
                                        }
                                
                        } else {
                                LoginView()
                                        .transition(.move(edge: .bottom))
                        }
                }
                .animation(.easeInOut, value: di.sessionStore.isLoading)
                .animation(.easeInOut, value: di.sessionStore.session)
        }
        
        // MARK: Logic Helper
        private func requestNotificationPermission() async {
                let center = UNUserNotificationCenter.current()
                
                do {
                        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                        
                        if granted {
                                print("Permission Notifications accordée !")
                        } else {
                                print("Permission Notifications refusée.")
                        }
                } catch {
                        print("Erreur Permission : \(error.localizedDescription)")
                }
        }
}

// MARK: Vue de Chargement
struct LoadingSplashView: View {
        var body: some View {
                ZStack {
                        Color(UIColor.systemBackground).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                                Image(systemName: "cross.case.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundStyle(.blue)
                                
                                Text("MediStock")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                
                                ProgressView()
                                        .controlSize(.large)
                                        .padding(.top, 20)
                        }
                }
        }
}
