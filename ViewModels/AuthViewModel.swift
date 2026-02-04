import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
        
        //MARK: Dependances
        private let authService: any AuthServiceProtocol
        private let userService: any UserServiceProtocol
        
        //MARK: Properties
        var email = ""
        var password = ""
        var isLoading = false
        var errorMessage: String?
        
        
        // MARK: Init
        init(authService: any AuthServiceProtocol, userService: any UserServiceProtocol) {
                self.authService = authService
                self.userService = userService
        }
        
        // MARK: Actions
        func signIn() async {
                await performAuthAction {
                        _ = try await self.authService.signIn(
                                email: self.email,
                                password: self.password)
                }
        }
        
        func signUp() async {
                await performAuthAction {
                        let user = try await self.authService.signUp(
                                email: self.email,
                                password: self.password)
                        try await self.userService.syncUser(user)
                }
        }
        
        // MARK: Private func
        private func performAuthAction(_ action: @escaping () async throws -> Void) async {
                isLoading = true
                errorMessage = nil
                
                do {
                        try await action()
                } catch let error as AuthServiceError {
                        self.errorMessage = error.errorDescription
                } catch {
                        self.errorMessage = error.localizedDescription
                }
                
                isLoading = false
        }
}
