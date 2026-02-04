//
//  LoginView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct LoginView: View {
        
        //MARK: depandence
        @Environment(DIContainer.self) private var di


        var body: some View {

                @Bindable var vm = di.authViewModel
                
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
                        
                        if let error = di.authViewModel.errorMessage {
                                Text(error).foregroundColor(.red).font(.caption)
                        }
                        
                        if di.authViewModel.isLoading {
                                ProgressView()
                        } else {
                                Button("Se connecter") {
                                        Task { await di.authViewModel.signIn() }
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("Créer un compte") {
                                        Task {
                                                print("Clic détecté : Lancement de signUp")
                                                await di.authViewModel.signUp()
                                        }
                                }
                        }
                }
                .padding()
        }
}
