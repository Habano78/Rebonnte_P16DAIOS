import Foundation
import Observation

// MARK: Erreurs de Session
enum SessionError: LocalizedError {
        case signOutFailed(Error)
        case unauthorized
        
        var errorDescription: String? {
                switch self {
                case .signOutFailed(let error): return "Déconnexion impossible : \(error.localizedDescription)"
                case .unauthorized: return "Session expirée ou non autorisée."
                }
        }
}


@MainActor
@Observable
final class SessionStore {
        // MARK: - State
        var session: User?
        var currentError: SessionError?
        private var isListening = false
        
        private let authService: any AuthServiceProtocol
        
        init(authService: any AuthServiceProtocol) {
                self.authService = authService
                // Le démarrage est sûr car contrôlé par isListening
                self.listen()
        }
        
        // MARK: - Logic
        func listen() {
                guard !isListening else { return } // Idempotence : évite les doublons
                isListening = true
                print("📡 SessionStore commence l'écoute...")
                Task {
                        for await user in authService.userStream() {
                                print("👤 SessionStore a reçu un utilisateur: \(user?.email ?? "nil")")
                                self.session = user
                        }
                }
        }
        
        func signOut() {
                do {
                        try authService.signOut()
                        self.currentError = nil
                } catch {
                        self.currentError = .signOutFailed(error)
                }
        }
}
