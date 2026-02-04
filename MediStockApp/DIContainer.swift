//
//  DIContainer.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class DIContainer {
        /// Services
        let authService: any AuthServiceProtocol
        let medicineService: any MedicineServiceProtocol
        let historyService: any HistoryServiceProtocol
        let userService: any UserServiceProtocol
        
        let sessionStore:  SessionStore
        
        /// ViewModels
        let authViewModel: AuthViewModel
        let medicineViewModel: MedicineStockViewModel
        
        //MARK: Init
        init() {
                let auth = FirebaseAuthService()
                let medicine = FirebaseMedicineService()
                let history = FirebaseHistoryService()
                let user = FirebaseUserService()
                
                self.authService = auth
                self.medicineService = medicine
                self.historyService = history
                self.userService = user

                self.sessionStore = SessionStore(authService: auth)
                
                self.authViewModel = AuthViewModel(
                        authService: auth,
                        userService: user)
                self.medicineViewModel = MedicineStockViewModel(
                        medicineService: medicine,
                        historyService: history,
                        authService: auth)
        }
}
