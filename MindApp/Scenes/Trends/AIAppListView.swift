//
//  AIAppList.swift
//  MindApp
//
//  Created by Jan Gutwirth on 08.03.2025.
//

import SwiftUI

struct AIAppListView: View {
    
    var aiApps: [AIApp]
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(aiApps.indices, id: \.self) { index in
                    let vm = DynamicAIAppViewModel(app: aiApps[index])
                    NavigationLink(destination: DynamicAIAppView().environmentObject(vm)) {
                        HStack {
                            Text(aiApps[index].localizations.first?.title ?? "No title")
                                .font(.appSenBody)
                                .foregroundStyle(Color.appTextBody)
                            
                            Spacer()
                            
                            Image(systemName: aiApps[index].iconName)
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.appButtonMain)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    AIAppListView(aiApps: AIApp.mockArray)
}
