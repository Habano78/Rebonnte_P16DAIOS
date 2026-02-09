// HistoryEntry.swift

import Foundation

struct HistoryEntry: Identifiable, Equatable, Sendable {
    let id: String
    let medicineId: String
    let userEmail: String
    let action: String
    let details: String
    let timestamp: Date
}

enum HistoryAction: String, Codable {
        case added = "Ajout Manuel"
        case modified = "Modification"
        case stockUpdate = "Mise à jour Stock"
        case deleted = "Suppression"
}
