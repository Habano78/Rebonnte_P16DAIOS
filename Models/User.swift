//
//  User.swift
//  MediStock
//
//  Created by Perez William on 03/02/2026.
//

import Foundation

struct User: Identifiable, Equatable, Sendable {
    let id: String
    let email: String
    let fullName: String?
    

    init(id: String, email: String, fullName: String? = nil) {
        self.id = id
        self.email = email
        self.fullName = fullName
    }
}
