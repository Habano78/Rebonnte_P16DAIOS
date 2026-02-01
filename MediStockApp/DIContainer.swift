//
//  DIContainer.swift
//  MediStock
//
//  Created by Perez William on 30/01/2026.
//

import Foundation

final class DIContainer: ObservableObject {
    // Abstractions (Protocoles)
    let authService: AuthServiceProtocol
    let medicineService: MedicineServiceProtocol
    let historyService: HistoryServiceProtocol
    let userService: UserServiceProtocol
    
    // État partagé
    let appSession: SessionStore

    init(
        authService: AuthServiceProtocol,
        medicineService: MedicineServiceProtocol,
        historyService: HistoryServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.authService = authService
        self.medicineService = medicineService
        self.historyService = historyService
        self.userService = userService
        self.appSession = SessionStore(authService: authService)
    }
}
