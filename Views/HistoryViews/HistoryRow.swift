//
//  HistoryRow.swift
//  MediStock
//
//  Created by Perez William on 06/02/2026.
//

import SwiftUI

// MARK: - Components
struct HistoryRow: View {
        let entry: HistoryEntry
        
        var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                        HStack {
                                // On affiche l'action en gras (ex: Mise à jour Stock)
                                Text(entry.action)
                                        .fontWeight(.semibold)
                                
                                Spacer()
                                
                                // Formatage de la date (ex: 6 February 2026)
                                Text(entry.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                        }
                        
                        // Détails de la modification (ex: Stock modifié de 0 à 20)
                        Text(entry.details)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
        }
}
