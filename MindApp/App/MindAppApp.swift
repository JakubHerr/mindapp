//
//  MindAppApp.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import SwiftUI

/// Main App struct that initializes all necessary background models and starts the app
@main
struct MindAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        setupNavigationBarAppearance()
        setupTabBarAppearance()
        setupSegmentedControlAppearance()
        setupLoaderAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
        }
    }
}

// MARK: - UIKit shenanigans

private extension MindAppApp {
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.appNavigationBarCompact,
            .foregroundColor: UIColor.appTextNavigationBar
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.appNavigationBarLarge,
            .foregroundColor: UIColor.appTextNavigationBar
        ]
        
        let appearanceCompacted = UINavigationBarAppearance()
        appearanceCompacted.configureWithOpaqueBackground()
        appearanceCompacted.backgroundColor = .clear
        appearanceCompacted.titleTextAttributes = [
            .font: UIFont.appNavigationBarCompact,
            .foregroundColor: UIColor.appTextNavigationBarInverse
        ]
        appearanceCompacted.largeTitleTextAttributes = [
            .font: UIFont.appNavigationBarLarge,
            .foregroundColor: UIColor.appTextNavigationBarInverse
        ]
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearanceCompacted
        
        let standardAppearance = appearanceCompacted.copy()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundColor = .appBackgroundTabBar
        
        UINavigationBar.appearance().standardAppearance = standardAppearance
        
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().tintColor = .appTintNavigationBar
    }

    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .appBackgroundTabBar
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.appTabBar,
            .foregroundColor: UIColor.appTintTabBarUnselected
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.appTabBar,
            .foregroundColor: UIColor.appTintTabBarSelected
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .appTintTabBarUnselected
        appearance.stackedLayoutAppearance.selected.iconColor = .appTintTabBarSelected
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func setupSegmentedControlAppearance() {
        UISegmentedControl.appearance().backgroundColor = .appBackgroundSegmentedControlGeneral
        UISegmentedControl.appearance().selectedSegmentTintColor = .appBackgroundSegmentedControlSelected
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.appTextItemTitleInverse],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.appTextItemTitle],
            for: .selected
        )
    }
    
    func setupLoaderAppearance() {
        let refreshLabel = NSLocalizedString("dailyview_refresh_label", comment: "Pull to refresh label")
        
        UIRefreshControl.appearance().tintColor = UIColor(Color.appBackgroundGradientBottom)
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: refreshLabel, attributes: [
            .foregroundColor: UIColor(Color.appBackgroundGradientBottom)
        ])
    }
}
