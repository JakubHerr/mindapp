//
//  SessionInfoView.swift
//  MindApp
//
//  Created by Daniel Davidík on 02.05.2024.
//

import SwiftUI

struct SessionInfoView: View {
    @State private var selectedTab = 0

    @EnvironmentObject var sessionViewModel: SessionViewModel

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                CustomSheetHeaderView(withBackButton: false)

                if let breathing = sessionViewModel.activity.breathing {
                    HStack(spacing: 30) {
                        Spacer()
                        VStack {
                            Image(systemName: "nose")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)

                            Text("\(breathing.inhaleDuration)")
                                .font(.appSenBody)

                            Text("mind_session_inhale")
                                .font(.custom("Sen", size: 14))
                        }

                        if let holdDuration = breathing.holdDuration {
                            VStack {
                                Image(systemName: "pause.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)

                                Text("\(holdDuration)")
                                    .font(.appSenBody)

                                Text("mind_session_hold")
                                    .font(.custom("Sen", size: 14))
                            }
                        }

                        VStack {
                            Image(systemName: "mouth")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)

                            Text("\(breathing.exhaleDuration)")
                                .font(.appSenBody)

                            Text("mind_session_exhale")
                                .font(.custom("Sen", size: 14))
                        }

                        if let secondHold = breathing.secondHoldDuration {
                            VStack {
                                Image(systemName: "pause.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)

                                Text("\(secondHold)")
                                    .font(.appSenBody)

                                Text("mind_session_hold")
                                    .font(.custom("Sen", size: 14))
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)
                }

                Text(sessionViewModel.activity.localization[0].title)
                    .font(.appSenTitle)
                    .bold()
                    .padding()

                Picker("", selection: $selectedTab) {
                    Text("mind_session_overview").tag(0)
                    Text("mind_session_when").tag(1)
                    Text("mind_session_science").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.clear)

                switch selectedTab {
                    case 0: OverviewView()
                    case 1: MindfulnessTypeView()
                    case 2: ScienceView()
                    default: OverviewView()
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SessionInfoView()
        .environmentObject(SessionViewModel.mock())
}
