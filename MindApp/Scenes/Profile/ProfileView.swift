//
//  ProfileView.swift
//  MindApp
//
//  Created by Michael Slavev on 28.05.2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel

    private let achievementsHeaderText = NSLocalizedString("profile_section_achievements", comment: "Section Achievements - header label")
    private let dayLabelText = NSLocalizedString("settings_achievements_day_label", comment: "Section Achievements - day label")
    private let totalMindMinutesText = NSLocalizedString("settings_achievements_totalmins", comment: "Section Achievements - total mind minutes label")
    private let currentStreakText = NSLocalizedString("settings_achievements_current_streak", comment: "Section Achievements - current streak label")
    private let topStreakText = NSLocalizedString("settings_achievements_top_streak", comment: "Section Achievements - top streak label")
    private let perefctWeekText = NSLocalizedString("settings_achievements_perfect_week", comment: "Section Achievements - perfect week label")
    private let perefctMonthText = NSLocalizedString("settings_achievements_perfect_month", comment: "Section Achievements - perfect month label")

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            ScrollView {
                VStack {
                    // MARK: Mindful history

                    Button(action: {
                        Task {
                            viewModel.toggleMindfulHistorySheet()
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Image(systemName: "clock.arrow.circlepath")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.appBackgroundGradientBottom)
                                .fontWeight(.bold)
                                .frame(width: 30, height: 30)
                                .padding(.top, 20)
                                .padding(.trailing, 20)
                        }

                    })
                    .sheet(isPresented: $viewModel.showingMindfulHistorySheet) {
                        MindfulnessHistorySheet()
                            .presentationDetents([.large])
                            .environmentObject(viewModel)
                    }

                    // MARK: Levels

                    VStack {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 6)
                                .opacity(0.3)
                                .foregroundColor(.gray)
                                .frame(width: 85, height: 85)

                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(Double(viewModel.currentXP) / Double(viewModel.xpForNextLevel), 1.0)))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.indigo, .green]), center: .center, startAngle: .degrees(0), endAngle: .degrees(360)
                                    ),
                                    style: StrokeStyle(lineWidth: 6, lineCap: .butt, lineJoin: .round)
                                )
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.linear, value: viewModel.currentXP)
                                .frame(width: 85, height: 85)

                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .foregroundColor(.appBackgroundGradientBottom)
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 20)

                        Text("Level \(viewModel.currentLevel)")
                            .font(.appSenTitle)
                            .foregroundColor(.appTextDark)
                            .bold()

                        Text("XP: \(viewModel.currentXP) / \(viewModel.xpForNextLevel)")
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                    }

                    // MARK: Achievements

                    Section(header:
                        Text(achievementsHeaderText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                    ) {
                        VStack {
                            StatisticView(title: totalMindMinutesText, value: "\(viewModel.totalMindfulnessSeconds / 60) min")

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            StatisticView(title: currentStreakText, value: "\(viewModel.currentStreak) \(dayLabelText)")

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            StatisticView(title: topStreakText, value: "\(viewModel.topStreak) \(dayLabelText)")
                        }
                        .padding()
                        .background(Color.appBackgroundGradientBottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])

                        HStack {
                            VStack {
                                StatisticView(title: perefctWeekText, value: "\(viewModel.perfectWeekCount) x")
                            }
                            .padding()
                            .background(Color.appBackgroundGradientBottom)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                            VStack {
                                StatisticView(title: perefctMonthText, value: "\(viewModel.perfectMonthCount) x")
                            }
                            .padding()
                            .background(Color.appBackgroundGradientBottom)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .padding([.horizontal])
                    }
                }
            }
        }
        .navigationTitle("profile_header")
        .refreshable {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.viewModel.fetchMindfulnessStatistics()
        }
        .onAppear {
            Task {
                await viewModel.fetchPartialActivities()
                await viewModel.fetchPartialActivitiesAllLocales()
            }
            self.viewModel.fetchMindfulnessStatistics()
        }
    }
}

struct StatisticView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.appSenBody)

            Spacer()

            Text(value)
                .font(.appSenBody)
                .bold()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileViewModel.mock())
}
