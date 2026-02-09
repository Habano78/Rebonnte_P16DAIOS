//
//  CategoryFilterView.swift
//  MediStock
//
//  Created by Perez William on 09/02/2026.
//

import SwiftUI

struct CategoryFilterView: View {
        
        @Environment(DIContainer.self) private var di
        
        private var viewModel: MedicineViewModel {
                di.medicineViewModel
        }
        
        private var currentUserId: String {
                di.sessionStore.session?.id ?? ""
        }
        
        var body: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                                
                               
                                FilterButton(
                                        title: "Tout",
                                        isSelected: viewModel.selectedCategory == nil
                                ) {
                                        Task {
                                                await viewModel.applyCategoryFilter(nil, userId: currentUserId)
                                        }
                                }
                                
                                // Boutons par Catégorie
                                ForEach(MedicineCategory.allCases, id: \.self) { category in
                                        FilterButton(
                                                title: category.rawValue,
                                                isSelected: viewModel.selectedCategory == category
                                        ) {
                                                Task {
                                                        await viewModel.applyCategoryFilter(category, userId: currentUserId)
                                                }
                                        }
                                }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                .background(Color(UIColor.systemGroupedBackground))
        }
}


struct FilterButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
                Button(action: action) {
                        Text(title)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .bold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(isSelected ? Color.blue : Color.white)
                                .foregroundColor(isSelected ? .white : .primary)
                                .clipShape(Capsule())
                                .overlay(
                                        Capsule()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
        }
}
