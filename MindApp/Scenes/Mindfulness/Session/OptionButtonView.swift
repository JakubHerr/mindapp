//
//  OptionButton.swift
//  MindApp
//
//  Created by Daniel Davidík on 16.05.2024.
//

import SwiftUI

struct OptionButtonView: View {
    var iconName: String
    var titleKey: LocalizedStringKey
    var text: String
    var seconds: Int?
    
    var isDisabled: Bool = false
    var isOn: Bool { text == onText }
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(isOn ? .black : .white)
            
            Text(titleKey)
                .font(.custom("Sen", size: 14))
                .foregroundColor(isOn ? .black.opacity(0.6) : .white.opacity(0.6))
            
            if let seconds = seconds, seconds > 0 {
                VStack(spacing: 0) {
                    Text(text)
                        .font(.custom("Sen", size: 12))
                        .foregroundColor(isOn ? .black : .white)
                                
                    Text("\(seconds) seconds")
                        .font(.custom("Sen", size: 12))
                        .foregroundColor(.white)
                }
            } else {
                Text(text)
                    .font(.custom("Sen", size: 14))
                    .foregroundColor(isOn ? .black : .white)
            }
        }
        .frame(width: 72, height: 50)
        .padding()
        .background(isOn ? Color.appAccentBright : Color.appButtonOption)
        .cornerRadius(15)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    OptionButtonView(iconName: "leaf", titleKey: "category", text: "", seconds: 10)
}
