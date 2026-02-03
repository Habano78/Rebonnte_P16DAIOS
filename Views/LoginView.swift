//
//  LoginView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct LoginView: View {
        
        //MARK: Deopendences
        @Environment(AuthViewModel.self) private var viewModel
        
        //MARK: Properties$
        @Bindable var viewModelBindable: AuthViewModel
        
        init(viewModel: AuthViewModel) {
                self.viewModelBindable = viewModel
        }
        
        //MARK: Body
        var body: some View {
                VStack(spacing: 20) {
                        Text("Connexion MediStock")
                                .font(.largeTitle).bold()
                        
                        VStack(alignment: .leading) {
                                TextField("Email", text: $viewModelBindable.email)
                                        .textFieldStyle(.roundedBorder)
                                        .autocapitalization(.none)
                                
                                SecureField("Mot de passe", text: $viewModelBindable.password)
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
                                        Task { await viewModel.signUp() }
                                }
                        }
                }
                .padding()
        }
}
