//
//  DIContainer.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import Foundation

/// A property wrapper for dependency injection for easier sharing of managers across classes in the app
@propertyWrapper
struct Injected<T> {
    let wrappedValue: T
    
    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}

/// Class holding all the shared managers to be accessed across the app
class DIContainer {
    static let shared: DIContainer = .init()
    
    var dependencies: [String: () -> Any] = [:]
    var cached: [String: Any] = [:]
    
    init() {
        registerDependencies()
    }
    
    func register<T, R>(type: T.Type, isCached: Bool = false, resolver: @escaping () -> R) {
        let name = String(describing: type)
        
        dependencies[name] = resolver
        
        if isCached {
            cached[name] = resolver()
        }
    }
    
    func resolve<T>() -> T {
        let name = String(describing: T.self)
        
        if let cachedObject = cached[name] as? T {
            return cachedObject
        }
        
        if let resolver = dependencies[name] as? (() -> T) {
            return resolver()
        }
        
        fatalError("Failed to initialize /\(T.self)")
    }
}

extension DIContainer {
    func registerDependencies() {
        register(type: AuthManager.self, isCached: true) {
            AuthManager()
        }
        
        register(type: HealthKitManager.self, isCached: true) {
            HealthKitManager()
        }
        
        register(type: HealthDBManager.self, isCached: true) {
            HealthDBManager()
        }
        
        register(type: MindfulnessDBManager.self, isCached: true) {
            MindfulnessDBManager()
        }
        
        register(type: DifyManager.self, isCached: true) {
            DifyManager()
        }

        register(type: CoreDataDBManager.self, isCached: true) {
            CoreDataDBManager()
        }
        
        register(type: AIAppDBManager.self, isCached: true) {
            AIAppDBManager()
        }
    }
}
