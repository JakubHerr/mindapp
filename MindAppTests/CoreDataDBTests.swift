//
//  CoreDataDBTests.swift
//  MindAppTests
//
//  Created by Jan Gutwirth on 05.02.2025.
//

import Testing
@testable import MindApp

extension Tag {
    @Tag static var dataRetention: Self
}

@Suite(.tags(.dataRetention), .serialized)
struct CoreDataDBTests {
    
    let mindfulnessTypes: [Activity.MindfulnessType] = Activity.MindfulnessType.mockArray
    let activities: [Activity] = Activity.mockArray
    
    var cdm: CoreDataDBManager = CoreDataDBManager()

    @Test func testMindfulnessTypesRetention() async throws {
        let tmpActivityTypes: [Activity.MindfulnessType] = cdm.fetchMindfulnessTypes()
        let tmpActivities: [Activity] = cdm.fetchActivities()
        
        cdm.deleteAll()
        
        cdm.saveMindfulnessTypes(types: mindfulnessTypes)
        
        let fetched = cdm.fetchMindfulnessTypes().sorted(by: { $0.id < $1.id })
        
        let sorted = mindfulnessTypes.sorted(by: { $0.id < $1.id })
        
        #expect(fetched == sorted)
        
        cdm.deleteAll()
        
        cdm.saveActivities(activities: tmpActivities)
        cdm.saveMindfulnessTypes(types: tmpActivityTypes)
    }
    
    
    @Test func testMindfulnessActivitiesRetention() async throws {
        let tmpActivities = cdm.fetchActivities()
        
        cdm.deleteActivities()
        
        cdm.saveActivities(activities: activities)
        
        let fetched = cdm.fetchActivities().sorted(by: { $0.name < $1.name })
        
        let sorted = activities.sorted(by: { $0.name < $1.name})
        
        #expect(fetched == sorted)
        
        cdm.deleteActivities()
        
        cdm.saveActivities(activities: tmpActivities)
    }
    
    @Test func testActivitiesDeletion() async throws {
        let tmpActivities = cdm.fetchActivities()
        
        cdm.deleteActivities()
        
        let fetched = cdm.fetchActivities()
        
        #expect(fetched.isEmpty)
        
        cdm.saveActivities(activities: tmpActivities)
    }

}
