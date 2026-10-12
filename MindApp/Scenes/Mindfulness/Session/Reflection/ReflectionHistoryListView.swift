//
//  ReflectionHistoryListView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 10.03.2025.
//

import SwiftUI

struct ReflectionHistoryListView: View {
    
    @StateObject private var vm: ReflectionHistoryViewModel = ReflectionHistoryViewModel()
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(Color.appCircleBackground)
                    .overlay(Circle().stroke(lineWidth: 2).foregroundStyle(Color.green))
                    .clipShape(RoundedRectangle(cornerRadius: 45))
            }
            else if vm.sessions.isEmpty && !vm.hasMoreData {
                Text("reflection_history_empty_title")
                    .foregroundStyle(Color.appTextBody)
                    .font(.appSenBody)
            }
            ScrollView {
                VStack {
                    ForEach(vm.sessions, id: \.id) { session in
                        NavigationLink(destination: ReflectionHistorySessionView(entry: session)) {
                            ReflectionHistoryListItemView(session: session)
                        }
                        .onAppear {
                            if session == vm.sessions.last {
                                vm.loadMoreReflections()
                            }
                        }
                    }
                }
                .padding()
                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            if vm.sessions.isEmpty {
                vm.loadMoreReflections()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "reflection_history_back_button")
                    .foregroundStyle(Color.appTextBody)                
            }
        }
        .dragGesture()
    }
}

#Preview {
    ReflectionHistoryListView()
        .environmentObject(ReflectionHistoryViewModel())
}
