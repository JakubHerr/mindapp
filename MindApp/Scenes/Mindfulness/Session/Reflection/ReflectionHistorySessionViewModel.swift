//
//  ReflectionHistorySessionViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 10.03.2025.
//

import Foundation

class ReflectionHistorySessionViewModel: ObservableObject {
    
    var date: Date
    
    var content: [(String, String)]
    
    init(date: Date, content: [(String, String)]) {
        self.date = date
        self.content = content
    }
    
    static var mock: ReflectionHistorySessionViewModel {
        ReflectionHistorySessionViewModel(date: Date(), content: [("Summary", "He was feeling good"), ("Mood", "7/10"), ("Tiredness", "3/10")])
    }
}
