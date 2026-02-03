//
//  RootView.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import SwiftUI

struct RootView: View {
        
        //MARK: Dependence
        @Environment(SessionStore.self) private var sessionStore
        
        //MARK: Body
        var body: some View {
                Group {
                        if sessionStore.session != nil {
                                MainTabView()
                        } else {
                                LoginView()
                        }
                }
        }
}

#Preview {
        RootView()
}
