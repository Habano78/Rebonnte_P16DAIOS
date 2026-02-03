//
//  LoginView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct LoginView: View {
        // On utilise uniquement l'Environment
        @Environment(AuthViewModel.self) private var viewModel
        
        var body: some View {
                // On crée le binding localement ICI
                @Bindable var vm = viewModel
                
                VStack(spacing: 20) {
                        Text("Connexion MediStock")
                                .font(.largeTitle).bold()
                        
                        VStack(alignment: .leading) {
                                TextField("Email", text: $vm.email)
                                        .textFieldStyle(.roundedBorder)
                                        .autocapitalization(.none)
                                
                                SecureField("Mot de passe", text: $vm.password)
                                        .textFieldStyle(.roundedBorder)
                        }
                        .padding()
                        
                        if let error = viewModel.errorMessage {
                                Text(error).foregroundColor(.red).font(.caption)
                        }
                        
                        if viewModel.isLoading {
                                ProgressView()
                        } else {
                                Button("Se connecter") {
                                        Task { await viewModel.signIn() }
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("Créer un compte") {
                                        Task {
                                                print("Clic détecté : Lancement de signUp")
                                                await viewModel.signUp()
                                        }
                                }
                        }
                }
                .padding()
        }
}
