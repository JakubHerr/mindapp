//
//  TimeView.swift
//  MindApp
//
//  Created by Daniel Davidík on 29.03.2024.
//

import SwiftUI

struct TimeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    var body: some View {
        ZStack {
            BackgroundGradientView()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 4) {
                    Text("mind_session_time")
                        .font(.appSenTitle).bold()
                        .foregroundStyle(Color.white)

                    HStack {
                        Picker(selection: self.$sessionViewModel.timeSelection.minutes, label: Text("Minutes")) {
                            ForEach(1...30, id: \.self) { minute in
                                Text("\(minute) m").tag(minute).foregroundStyle(Color.appTextBody).fontWeight(.bold)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 110, height: 150)
                        .clipped()
                        .compositingGroup()

                        Picker(selection: self.$sessionViewModel.timeSelection.seconds, label: Text("Seconds")) {
                            ForEach(0...59, id: \.self) { second in
                                Text("\(second) s").tag(second).foregroundStyle(Color.appTextBody).fontWeight(.bold)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 110, height: 150)
                        .clipped()
                        .compositingGroup()
                    }
                    .background(Color.clear)
                }

                HStack {
                    Text("mind_time_preset")
                        .font(.custom("Sen", size: 18))
                        .foregroundStyle(Color.white)
                        .padding(.leading, 42)

                    Spacer()
                }.padding(.top)

                HStack(spacing: 16) {
                    ForEach([3, 5, 10], id: \.self) { minute in
                        Button("\(minute) M") {
                            self.sessionViewModel.timeSelection.minutes = minute
                        }
                        .timerButtonStyle()
                    }
                }

                Button("mind_time_unlimited") {
                    self.sessionViewModel.timeSelection.minutes = 0
                    self.sessionViewModel.timeSelection.seconds = 0
                }
                .textCase(.uppercase)
                .timerButtonStyle()

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(title: "back")
            }
        }
        .dragGesture()
    }
}

struct TimerButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sen", size: 18).bold())
            .foregroundColor(.appButtonAccent)
            .padding(EdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 32))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appButtonAccent, lineWidth: 1)
            )
    }
}

extension View {
    func timerButtonStyle() -> some View {
        modifier(TimerButtonStyle())
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView()
            .environmentObject(SessionViewModel.mock())
    }
}
