//
//  Color+App.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import SwiftUI

// MARK: - SwiftUI

extension Color {
    static let appBackgroundGradientTop = Color("Colors/Background/Gradient/Top")
    static let appBackgroundGradientBottom = Color("Colors/Background/Gradient/Bottom")
    static let appBackgroundLightGradientTop = Color("Colors/Background/Gradient/Light Top")
    static let appBackgroundLightGradientBottom = Color("Colors/Background/Gradient/Light Bottom")
    static let appBackgroundItem = Color("Colors/Background/Item")
    static let appAccentBright = Color("Colors/Accent/Bright")
    static let appAccentBright2 = Color("Colors/Accent/Bright 2")
    static let appAccentGreenDark = Color("Colors/Accent/Green Dark")
    static let appBackgroundGreenMain = Color("Colors/Background/Green Main")
    static let appCircleBackground = Color("Colors/Background/Circle")
    static let appSessionBackground = Color("Colors/Background/Tab Bar")

    static let appTextBody = Color("Colors/Text/Body")
    static let appTextSectionTitle = Color("Colors/Text/Section Title")
    static let appTextItemTitle = Color(uiColor: .appTextItemTitle)
    static let appTextNavigationBar = Color(uiColor: .appTextNavigationBar)
    static let appTextDark = Color("Colors/Text/Dark")

    static let appButtonMain = Color("Colors/Button/Main")
    static let appButtonAccent = Color("Colors/Button/Accent")
    static let appButtonOption = Color("Colors/Button/Option")
    static let appButtonOptionSelected = Color("Colors/Button/Selected")

    static let appGraphMindfulness = Color("Colors/Graph/Mindfulness")

    static let appLogoMain = Color("Colors/Logo/Main")
}

// MARK: - UIKit

extension UIColor {
    static let appBackgroundTabBar = UIColor(named: "Colors/Background/Tab Bar")!
    static let appBackgroundSegmentedControlGeneral = UIColor(named: "Colors/Background/Segmented Control/General")!
    static let appBackgroundSegmentedControlSelected = UIColor(named: "Colors/Background/Segmented Control/Selected")!

    static let appTextNavigationBar = UIColor(named: "Colors/Text/Navigation Bar")!
    static let appTextNavigationBarInverse = UIColor(named: "Colors/Text/Navigation Bar Inverse")!

    static let appTintNavigationBar = UIColor(named: "Colors/Tint/Navigation Bar")!
    static let appTintTabBarSelected = UIColor(named: "Colors/Tint/Tab Bar/Selected")!
    static let appTintTabBarUnselected = UIColor(named: "Colors/Tint/Tab Bar/Unselected")!

    static let appTextItemTitle = UIColor(named: "Colors/Text/Item Title")!
    static let appTextItemTitleInverse = UIColor(named: "Colors/Text/Item Title Inverse")!

    static let appGraphMindfulness = UIColor(named: "Colors/Graph/Mindfulness")!
}
