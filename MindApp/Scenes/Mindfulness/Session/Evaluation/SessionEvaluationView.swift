//
//  SessionEvaluationView.swift
//  MindApp
//
//  Created by Daniel Davidík on 13.04.2024.
//

import SwiftUI

/// View showing the evaluation of given activity session
/// > Important: Needs to be provided with ``NavPathRouter`` and ``SessionViewModel`` as environmentObjects
struct SessionEvaluationView: View {
    @EnvironmentObject var router: NavPathRouter
    @EnvironmentObject var sessionViewModel: SessionViewModel

    @StateObject var viewModel = SessionEvaluationViewModel()
    @StateObject var soundViewModel = SoundViewModel()

    var body: some View {
        VStack {
            Spacer()

            Text("mind_session_evaluation")
                .font(.appSenTitle)
                .bold()
                .foregroundColor(Color.white)
                .padding()

            List {
                ForEach(Feeling.allCases, id: \.id) { feeling in
                    self.makeButton(feeling: feeling)
                }
            }
            .padding()
            .scrollContentBackground(.hidden)
            .listStyle(InsetGroupedListStyle())
            .frame(maxHeight: 250)

            Spacer()

            Button(action: {
                Task {
                    await self.viewModel.addMindfulMinutes(feeling: self.viewModel.selectedFeeling, activity: self.sessionViewModel.activity, startTime: self.sessionViewModel.getStartTime(), endTime: self.sessionViewModel.getEndTime())
                }
                self.router.navigateToRoot()
            }) {
                Text("continue")
                    .font(.appSenBody)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.appButtonOption)
                    .cornerRadius(30)
                    .padding()
            }
        }
        .onAppear {
            if !self.sessionViewModel.isChimeOn { return }

            self.soundViewModel.playSound(named: "Zen Gong", volume: self.sessionViewModel.volume, numberOfLoops: 0)
        }
        .onDisappear {
            self.soundViewModel.stopAllSounds()
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.appSessionBackground.edgesIgnoringSafeArea(.all))
    }

    func makeButton(feeling: Feeling) -> some View {
        Button(action: {
            self.viewModel.selectedFeeling = feeling
        }) {
            HStack {
                Image(systemName: feeling == self.viewModel.selectedFeeling ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(Color.white)
                Text(feeling.rawValue)
                    .foregroundColor(Color.white)
                    .font(.appSenBody)
            }
        }
        .listRowBackground(self.viewModel.selectedFeeling == feeling ? Color.appButtonOptionSelected : Color.appButtonOption)
    }
}

struct SessionEvaluationView_Previews: PreviewProvider {
    static var previews: some View {
        SessionEvaluationView()
            .environmentObject(NavPathRouter.mock())
            .environmentObject(SessionViewModel.mock())
    }
}
