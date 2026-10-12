//
//  Alignment+Custom.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import SwiftUI

extension HorizontalAlignment {
    struct HorizontalInfoAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[.leading]
        }
    }
    
    static let horizontalInfoAlignment: HorizontalAlignment = HorizontalAlignment(HorizontalInfoAlignment.self)
}
