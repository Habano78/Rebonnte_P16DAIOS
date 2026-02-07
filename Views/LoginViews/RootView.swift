//
//  RootView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct RootView: View {
        
        //MARK: Dependence
        @Environment(DIContainer.self) private var di
        
        
        //MARK: Body
        var body: some View {
                Group {
                        if di.sessionStore.session != nil {
                                MainTabView()
                        } else {
                                LoginView()
                        }
                }
        }
}
