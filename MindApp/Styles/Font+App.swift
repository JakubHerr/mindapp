//
//  Font+App.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import SwiftUI

// MARK: - SwiftUI

extension Font {
    static func clashDisplayVariableBoldSemibold(ofSize size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom("ClashDisplayVariable-Bold_Semibold", size: size, relativeTo: textStyle)
    }

    static func satoshiVariableBoldBold(ofSize size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom("SatoshiVariable-Bold_Bold", size: size, relativeTo: textStyle)
    }

    static func senVariable(ofSize size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom("Sen", size: size, relativeTo: textStyle)
    }
}

extension Font {
    static let appSectionTitle = clashDisplayVariableBoldSemibold(ofSize: 18, relativeTo: .title)

    static let appItemLargeTitle = clashDisplayVariableBoldSemibold(ofSize: 18, relativeTo: .title)
    static let appItemSmallTitle = clashDisplayVariableBoldSemibold(ofSize: 13, relativeTo: .title)
    static let appItemDescription = clashDisplayVariableBoldSemibold(ofSize: 13, relativeTo: .body)

    static let appSenTitle = senVariable(ofSize: 24, relativeTo: .title)
    static let appSenBody = senVariable(ofSize: 16, relativeTo: .body)
}

// MARK: - UIKit

extension UIFont {
    static func clashDisplayVariableBoldSemibold(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "ClashDisplayVariable-Bold_Semibold", size: size) else {
            // Fallback font or handle the error appropriately
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

    static func senVariable(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Sen", size: size) else {
            // Fallback font or handle the error appropriately
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}

extension UIFont {
    static let appNavigationBarLargeBase = senVariable(ofSize: 28)
    static let appNavigationBarLarge = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .appNavigationBarLargeBase)

    static let appNavigationBarCompactBase = senVariable(ofSize: 18)
    static let appNavigationBarCompact = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .appNavigationBarCompactBase)

    static let appTabBarBase = clashDisplayVariableBoldSemibold(ofSize: 11)
    static let appTabBar = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .appTabBarBase)
}
