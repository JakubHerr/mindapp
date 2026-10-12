//
//  CountdownView.swift
//  MindApp
//
//  Created by Daniel Davidík on 04.04.2024.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case meditationView
    case breathingView
    case sessionEvaluationView
    case reflectionView
    case reflectionSession
    case reflectionEvaluation
}

class NavPathRouter: ObservableObject {
    @Published var path: NavigationPath = .init()

    func navigateTo(_ route: NavigationDestination) {
        path.append(route)
    }

    func navigateBack() {
        path.removeLast()
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    static func mock() -> NavPathRouter {
        return NavPathRouter()
    }
}

struct CountdownView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var timeRemaining = 10
    @State private var isActive = true

    @StateObject var navPathRouter: NavPathRouter = .init()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack(path: $navPathRouter.path) {
            ZStack {
                Color.appSessionBackground.edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    Text("mind_session_starts")
                        .font(.appSenTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    ZStack {
                        Circle()
                            .fill(Color.appCircleBackground)
                            .frame(width: 195, height: 195)

                        Circle()
                            .stroke(lineWidth: 5.0)
                            .opacity(0.3)
                            .foregroundColor(Color.black)

                        Circle()
                            .trim(from: 0.0, to: 1.0 - CGFloat(min(Double(timeRemaining) / 10.0, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.white)
                            .rotationEffect(Angle(degrees: -90))
                            .animation(.linear, value: timeRemaining)

                        Text("\(timeRemaining)")
                            .font(.custom("Sen", size: 30))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 200, height: 200)
                    .padding(40)
                    .onReceive(timer) { _ in
                        if self.isActive && self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        } else {
                            let destination: NavigationDestination = sessionViewModel.activity.category == .breathing ? .breathingView : .meditationView

                            navPathRouter.navigateTo(destination)
                            self.timer.upstream.connect().cancel()
                        }
                    }

                    Text("mind_session_prepare")
                        .foregroundColor(.appAccentBright)
                        .font(.custom("Sen", size: 14))

                    Spacer()

                    Button(action: {
                        self.isActive = false
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("cancel")
                            .font(.appSenBody).bold()
                            .foregroundColor(.appTextDark)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appAccentBright)
                            .cornerRadius(30)
                    }
                    .padding()
                }
            }
            .onAppear {
                if self.timeRemaining == 0 {
                    self.presentationMode.wrappedValue.dismiss()
                }
                self.isActive = true
            }
            .onDisappear {
                self.isActive = false
                self.timer.upstream.connect().cancel()
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .meditationView:
                    MeditationView()
                case .breathingView:
                    BreathingView()
                case .sessionEvaluationView:
                    SessionEvaluationView()
                default:
                    Text("Unknown case received: \(destination)")
                }
            }
        }
        .environmentObject(sessionViewModel)
        .environmentObject(BreathingViewModel(activity: sessionViewModel.activity))
        .environmentObject(navPathRouter)
        .navigationBarBackButtonHidden(true)
        .dragGesture()
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView()
            .environmentObject(SessionViewModel.mock())
    }
}
