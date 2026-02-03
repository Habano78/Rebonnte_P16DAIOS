import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable

final class SessionStore {
        
        //MARK: Properties
        var session: User?
        var errorMessage: String?
        private let authService: any AuthServiceProtocol
        private nonisolated var handle: AuthStateDidChangeListenerHandle?
        
        init(authService: any AuthServiceProtocol) {
                self.authService = authService
                self.listen()
        }
        
        func listen() {
                handle = authService.observeAuthState { [weak self] user in
                        Task { @MainActor in
                                self?.session = user
                        }
                }
        }
        
        func signOut() {
                do {
                        try authService.signOut()
                        self.errorMessage = nil
                } catch {
                        self.errorMessage = error.localizedDescription
                }
        }
        
        deinit {
                if let handle = handle {
                        authService.removeAuthStateListener(handle)
                }
        }
}

///Le SessionStore est le gestionnaire de l'état global de l'utilisateur. Son rôle est de maintenir en permanence la "Source de Vérité" sur l'identité de la personne qui utilise l'application.
