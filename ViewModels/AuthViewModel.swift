//
//  AuthViewModel.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
        var email = ""
        var password = ""
        var isLoading = false
        var errorMessage: String?
        
        private let authService: any AuthServiceProtocol
        private let userService: any UserServiceProtocol
        
        init(authService: any AuthServiceProtocol, userService: any UserServiceProtocol) {
                self.authService = authService
                self.userService = userService
        }
        
        func signIn() async {
                await performAuthAction {
                        let user = try await self .authService.signIn(email: self .email, password: self .password)
                        try await self.userService.syncUser(user)
                }
        }
        
        func signUp() async {
                await performAuthAction {
                        let user = try await self .authService.signUp(email: self .email, password: self .password)
                        try await self .userService.syncUser(user)
                }
        }
        
        private func performAuthAction(_ action: @escaping () async throws -> Void) async {
                isLoading = true
                errorMessage = nil
                do {
                        try await action()
                } catch {
                        errorMessage = error.localizedDescription
                }
                isLoading = false
        }
}
