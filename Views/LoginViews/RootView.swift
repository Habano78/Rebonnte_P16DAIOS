//
//  RootView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct RootView: View {
        
        //MARK: Dependence
        @Environment(DIContainer.self) private var container
        
        //MARK: Body
        var body: some View {
                Group {
                        if container.sessionStore.session != nil {
                                MedicineListView()
                        } else {
                                LoginView()
                        }
                }
                .animation(.easeInOut, value: container.sessionStore.session != nil)
                .task {
                        _ = await container.notificationService.requestPermission()
                }
        }
}
