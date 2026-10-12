//
//  MindAppTests.swift
//  MindAppTests
//
//  Created by Jan Gutwirth on 25.01.2025.
//

import Testing
@testable import MindApp

extension Tag {
    @Tag static var database: Self
}

@Suite(.tags(.database))
struct MindfulnessDBTests {

    var mdbm: MindfulnessDBManager = MindfulnessDBManager()
    
    @Test func activitiesFetchTest() async throws {
        let activities = try await mdbm.fetchActivities()
        
        #expect(!activities.isEmpty, "No activities found")
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func categoriesFetchTest() async throws {
        let categories = try await mdbm.fetchMindfulnessTypes()
        
        #expect(!categories.isEmpty, "No categories found")
    }
}
