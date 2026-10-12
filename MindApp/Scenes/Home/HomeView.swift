//
//  HomeView.swift
//  MindApp
//
//  Created by Michael Slavev on 22.03.2024.
//

import SwiftUI

/// The first view a logged user should see with the ability to toggle between  ``DailyView``, ``TrendsView``, ``CategoriesView``, ``ProfileView`` and ``SettingsView``
///
/// > Initializes most of the app's core viewmodels
struct HomeView: View {
    @StateObject private var healthkitViewModel = HealthkitViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var categoriesViewModel = CategoriesViewModel()
    @StateObject private var chooseSessionViewModel = ChooseSessionViewModel()
    @StateObject private var dailyViewModel = DailyViewModel()

    var body: some View {
        TabView {
            // MARK: Home tab
            
            NavigationView {
                DailyView()
                    .environmentObject(healthkitViewModel)
                    .environmentObject(dailyViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "house")
                
                Text("nav_home")
            }
            
            // MARK: Trends Tab
            
            NavigationView {
                TrendsView()
                    .environmentObject(healthkitViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                
                Text("nav_trends")
            }
            
            // MARK: Mindfulness tab
            
            NavigationView {
                CategoriesView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "figure.mind.and.body")
                
                Text("nav_mindful")
            }
            
            // MARK: Profile tab
            
            NavigationView {
                ProfileView().environmentObject(profileViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                
                Text("nav_profile")
            }
            
            // MARK: Settings tab
            
            NavigationView {
                SettingsView().environmentObject(settingsViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "gearshape.fill")
                
                Text("nav_settings")
            }
        }
        .onAppear {
            Task {
                await chooseSessionViewModel.fetchMindfulnessTypes()
                await categoriesViewModel.fetchActivities()
            }
        }
        .environmentObject(categoriesViewModel)
        .environmentObject(chooseSessionViewModel)
        .navigationBarBackButtonHidden(true)
        .foregroundColor(.appTextBody)
        .preferredColorScheme(.none)
    }
}

#Preview {
    HomeView()
}
