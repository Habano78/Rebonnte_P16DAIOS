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
        
        //MARK: Dependence
        private let authService: any AuthServiceProtocol
        
        // MARK:  State
        var session: User?
        var currentError: SessionError?
        var userEmail: String?
        
        private var isListening = false
        
        
        //MARK: Init
        init(authService: any AuthServiceProtocol) {
                self.authService = authService
                self.listen()
        }
        
        // MARK: - Logic
        func listen() {
                guard !isListening else { return }
                isListening = true
                
                Task {
                        for await user in authService.userStream() {
                                
                                session = user
                                userEmail = user?.email
                                
                                print("SessionStore a reçu un utilisateur: \(user?.email ?? "nil")")
                        }
                }
        }
        
        func signOut() {
                do {
                        try authService.signOut()
                        
                        self.session = nil
                        self.userEmail = nil
                        self.currentError = nil
                        
                } catch {
                        self.currentError = .signOutFailed(error)
                }
        }
}
