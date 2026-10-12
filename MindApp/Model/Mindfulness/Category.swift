//
//  Category.swift
//  MindApp
//
//  Created by Daniel Davidík on 29.04.2024.
//

import Foundation
import SwiftUI

enum MindfulnessCategory: String, Codable, Equatable {
    case breathing = "Breathing"
    case meditation = "Meditation"

    var localized: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}
