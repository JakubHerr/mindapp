//
//  ReflectionCardView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 15.10.2024.
//

import SwiftUI

struct ReflectionCardView: View {
    var iconName: String = "brain"
    var description: LocalizedStringKey = "reflection_card_description"
    var name: String = "Chat with AI"
    
    var body: some View {
        NavigationLink(destination: ReflectionView()) {
            VStack {
                HStack {
                    Text("reflection_card_title")
                        .font(.appSenTitle)
                        .foregroundStyle(Color.white)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding()
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.green)
                
                Text(description)
                    .font(.appSenBody)
                    .foregroundColor(.appTextBody)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.appButtonMain)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }

}

#Preview {
    ReflectionCardView()
}
