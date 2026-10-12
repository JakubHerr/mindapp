//
//  ReflectionView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 23.02.2025.
//

import SwiftUI

struct ReflectionView: View {
    
    @Injected var hkm: HealthKitManager
        
    @State var isAvailable: Bool = true
    
//    @State var fetchedSessions: [ReflectionEntry] = []
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var date: Date?
    
    @State var timeRemaining: String = ""
    
    var body: some View {
        ZStack {
            Color.appSessionBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("reflection_view_title")
                    .font(.appSenTitle)
                    .foregroundStyle(Color.appTextBody)
                ScrollView {
                    Text("reflection_description")
                        .font(.appSenBody)
                        .foregroundStyle(Color.appTextBody)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .scrollIndicators(.hidden)
                Spacer()
                NavigationLink(destination: ReflectionHistoryListView()) {
                    HStack {
                        Text("reflection_history")
                            .font(.appSenBody)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appTextBody)
                    }
                    .padding()
                    .background(Color.appButtonMain)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                NavigationLink(destination: ReflectionSessionView()) {
                    Text("start_reflection_session_button")
                        .font(.appSenBody)
                        .padding()
                        .background(Color.appButtonMain)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .opacity(isAvailable ? 1 : 0.5)
                }
                .disabled(!isAvailable)
                Text("next_summary_generation_available_in: \(timeRemaining)")
                    .font(.appSenBody)
                    .foregroundStyle(Color.appTextBody)
                    .multilineTextAlignment(.center)
                    .padding()
                    .onReceive(timer) { _ in
                        checkAvailability()
                        updateCountdown()
                    }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "reflection_back_button")
                    .foregroundStyle(Color.appTextBody)
            }
        }
        .onAppear {
            checkAvailability()
        }
        .navigationBarBackButtonHidden(true)
        .dragGesture()
    }
    
    func checkAvailability() {
        Task {
            do {
                if let reflection = try await hkm.fetchLatestReflection() {
                    date = reflection.startDate
                    let diff = abs(reflection.startDate.timeIntervalSinceNow)
//                    if diff > 12 * 60 * 60 {
                    if diff > 10 {
                        self.isAvailable = true
                    }
                    else {
                        self.isAvailable = false
                    }
                }
                else {
                    self.isAvailable = true
                    timeRemaining = "Ready"
                }
            }
            catch {
                Logger.log("Fetch of last reflection failed: \(error)", .error)
                self.isAvailable = false
            }
        }
    }
    
    func updateCountdown() {
        guard let lastDate = date else {
//            Logger.log("No starting date found", .error)
            return
        }
        
//        let endDate = Calendar.current.date(byAdding: .hour, value: 12, to: lastDate)!
//        let endDate = Calendar.current.date(byAdding: .minute, value: 1, to: lastDate)!
        let endDate = Calendar.current.date(byAdding: .second, value: 10, to: lastDate)!
        let now = Date()
        
        let timeInterval = endDate.timeIntervalSince(now) // Time remaining to reach lastDate + 12h
        
        if timeInterval <= 0 {
            timeRemaining = "Time's up!"
        } else {
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

#Preview {
    ReflectionView()
}
