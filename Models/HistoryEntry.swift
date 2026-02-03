// HistoryEntry.swift

import Foundation

struct HistoryEntry: Identifiable, Equatable, Sendable {
    let id: String
    let medicineId: String
    let userEmail: String // On passe de l'ID à l'email pour l'UX
    let action: String
    let details: String
    let timestamp: Date
}

