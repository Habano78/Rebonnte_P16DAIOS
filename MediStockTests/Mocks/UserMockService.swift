//
//  UserMockService.swift
//  MediStockTests
//
//  Created by Perez William on 07/02/2026.
//

import Foundation
@testable import MediStock


//MARK: User Service

@MainActor
final class MockUserService: UserServiceProtocol {
        
        var shouldFail = false
        var wasSyncCalled = false
        
        func syncUser(_ user: User) async throws {
                if shouldFail { throw MockError.testFailure }
                wasSyncCalled = true
        }
        
        func fetchUser(id: String) async throws -> User? {
                if shouldFail { throw MockError.testFailure }
                return User(id: id, email: "test@test.com")
        }
}
