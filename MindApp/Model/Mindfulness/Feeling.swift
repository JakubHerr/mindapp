//
//  Feeling.swift
//  MindApp
//
//  Created by Daniel Davidík on 19.05.2024.
//

import Foundation
import SwiftUI

enum Feeling: LocalizedStringKey, Hashable, Identifiable, CaseIterable {
    var id: Int { self.hashValue }

    case better = "mind_session_evaluation_better"
    case same = "mind_session_evaluation_same"
    case worse = "mind_session_evaluation_worse"

    var dbName: String {
        switch self {
        case .better: "Better"
        case .same: "Same"
        case .worse: "Worse"
        }
    }
}
