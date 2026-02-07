//
//  ProfileView.swift
//  MediStock
//
//  Created by Perez William on 07/02/2026.
//

import SwiftUI

struct ProfileView: View {
        
        // MARK: - Dependences
        @Environment(DIContainer.self) private var di
        
        // MARK: - Body
        var body: some View {
                NavigationStack {
                        Form {
                                // Section Information Utilisateur
                                Section("Mon Profil") {
                                        LabeledContent("Email") {
                                                Text(di.sessionStore.userEmail ?? "Inconnu")
                                                        .foregroundColor(.secondary)
                                        }
                                        // On peut imaginer ici d'autres infos comme le rôle (Admin/Opérateur)
                                        LabeledContent("Rôle", value: "Administrateur")
                                }
                                
                                // Section Actions
                                Section {
                                        Button(role: .destructive) {
                                                di.sessionStore.signOut()
                                        } label: {
                                                HStack {
                                                        Spacer()
                                                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                                                        Spacer()
                                                }
                                        }
                                }
                        }
                        .navigationTitle("Compte")
                }
        }
}
