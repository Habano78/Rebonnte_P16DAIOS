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
                                Text(entry.action)
                                        .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text(entry.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                        }
                        
                        Text(entry.details)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
        }
}
