//
//  WelcomeView.swift
//  MindApp
//
//  Created by Daniel Davidík on 21.03.2024.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundLightGradientView()
                
                VStack {
                    VStack {
                        Image("mind-app-transparent")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 160)
                            .foregroundStyle(Color.appLogoMain)
                        
                        Text("welcome")
                            .padding([.leading, .trailing], 16)
                            .font(.appSenTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("welcome_desc")
                            .font(.appSenBody)
                            .padding([.leading, .trailing], 64)
                            .padding([.top], 4)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .padding([.top], 48)
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        NavigationLink(destination: SignUpView()) {
                            Text("create_acc")
                                .font(.appSenBody)
                                .bold(true)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.appButtonMain)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        
                        NavigationLink(destination: SignInView()) {
                            Text("sign_to")
                                .font(.appSenBody)
                                .bold(true)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.appTextDark)
                                .background(Color.appButtonAccent)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
 
