//
//  NotificationService.swift
//  MediStock
//
//  Created by Perez William on 08/02/2026.
//

import UserNotifications

//MARK: Protocol
protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
}

//MARK: Implementation
final class NotificationService: NotificationServiceProtocol {
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Erreur Permission Notifications : \(error.localizedDescription)")
            return false
        }
    }
}
