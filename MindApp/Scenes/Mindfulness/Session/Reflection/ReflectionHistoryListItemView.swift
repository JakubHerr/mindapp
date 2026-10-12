//
//  ReflectionHistoryListItemView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 10.03.2025.
//

import SwiftUI

class ReflectionEntry: ObservableObject, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var contents: [(String, String)]
    
    init(date: Date, contents: [(String, String)]) {
        self.date = date
        self.contents = contents
    }
    
    static func == (lhs: ReflectionEntry, rhs: ReflectionEntry) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.date != rhs.date {
            return false
        }
        return true
    }
    
    static var mock: ReflectionEntry {
        return ReflectionEntry(date: Date(), contents: [("Summary", "He was feeling good"), ("Mood", "7/10"), ("Tiredness", "3/10")])
    }
}

struct ReflectionHistoryListItemView: View {
    
    @StateObject var session: ReflectionEntry
    
    var body: some View {
        HStack {
            Text(formattedDate(session.date))
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .foregroundStyle(Color.appTextBody)
        .background(Color.appBackgroundGreenMain)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long   // Example: "March 10, 2025"
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ReflectionHistoryListItemView(session: ReflectionEntry.mock)
}
