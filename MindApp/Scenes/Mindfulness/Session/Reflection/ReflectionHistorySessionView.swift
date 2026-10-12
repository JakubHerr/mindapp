//
//  ReflectionHistorySessionView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 10.03.2025.
//

import SwiftUI

struct ReflectionHistorySessionView: View {
    
    @StateObject var entry: ReflectionEntry
    
//    private let backButtonTitle: LocalizedStringKey = "reflection_history_item_back"
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            VStack {
                Text("reflection_history_session_title")
                    .font(.appSenTitle)
                Text("reflection_history_date:")
                    .font(.headline)
                Text(formattedDate(entry.date))
                    .font(.appSenBody)
                    .multilineTextAlignment(.center)
                ForEach(entry.contents, id: \.0) { key, value in
                    if key != "SourceApp" && key != "Type" {
                        VStack {
                            Text(key)
                                .font(.headline)
                            Text(value)
                                .font(.body)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                }
            }
            .foregroundStyle(Color.appTextBody)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(title: "reflection_history_item_back")
                    .foregroundStyle(Color.appTextBody)
            }
        }
        .dragGesture()
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long   // Example: "March 10, 2025"
        formatter.timeStyle = .short   // Removes time zone and time
        return formatter.string(from: date)
    }
}

#Preview {
    ReflectionHistorySessionView(entry: ReflectionEntry.mock)
}
