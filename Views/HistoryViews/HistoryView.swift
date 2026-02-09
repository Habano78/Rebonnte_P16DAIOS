//
//  HistoryView.swift
//  MediStock
//
//  Created by Perez William on 06/02/2026.
//

import SwiftUI

struct HistoryView: View {
        @Environment(DIContainer.self) private var di
        
        var body: some View {
                NavigationStack {
                        List(di.medicineViewModel.history) { entry in
                                VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                                Image(systemName: iconForAction(entry.action))
                                                        .foregroundColor(colorForAction(entry.action))
                                                
                                                Text(entry.action)
                                                        .fontWeight(.bold)
                                                
                                                Spacer()
                                                
                                                Text(entry.timestamp, style: .date)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                        }
                                        
                                        Text(entry.details)
                                                .font(.subheadline)
                                        
                                        Text("Par : \(entry.userEmail)")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                        }
                        .navigationTitle("Historique Global")
                        .refreshable {
                                await di.medicineViewModel.fetchAllHistory()
                        }
                        .task {
                                await di.medicineViewModel.fetchAllHistory()
                        }
                }
        }
        
        // Fonctions d'aide pour l'UI
        private func iconForAction(_ action: String) -> String {
                switch action {
                case HistoryAction.added.rawValue: return "plus.circle.fill"
                case HistoryAction.stockUpdate.rawValue: return "arrow.up.arrow.down.circle.fill"
                case HistoryAction.modified.rawValue: return "pencil.circle.fill"
                default: return "clock.fill"
                }
        }
        
        private func colorForAction(_ action: String) -> Color {
                switch action {
                case HistoryAction.added.rawValue: return .green
                case HistoryAction.stockUpdate.rawValue: return .orange
                default: return .blue
                }
        }
}
