//
//  ContentView.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
                case .Initial:
                    InitView()

                case .SignedIn:
                    HomeView()

                case .SignedOut:
                    WelcomeView()
            }
        }
        .task {
            await authViewModel.isUserSignIn()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthViewModel.mock())
    }
}
