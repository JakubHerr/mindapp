//
//  DailyStressView.swift
//  MindApp
//
//  Created by Michael Slavev on 03.04.2024.
//

import SwiftUI

/// Shows the daily section of the app, showing some recent stats etc.
/// > Important: Needs to get ``DailyViewModel`` and ``HealthkitViewModel`` as environmentObjects in order to function
///
/// Example usage:
/// ```swift
/// let dvm: DailyViewModel = DailyViewModel()
/// let hkvm: HealthKitViewModel = HealthKitViewModel()
/// ...
/// DailyView()
///     .environmentObject(dvm)
///     .environmentObject(hkvm)
/// ```
struct DailyView: View {
    @EnvironmentObject private var viewModel: DailyViewModel
    @EnvironmentObject var healthkitViewModel: HealthkitViewModel
    @Environment(\.scenePhase) var scenePhase

    @State private var selectedDate: Date = .init()

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            ScrollView {
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                            }
                            Task {
                                await self.healthkitViewModel.fetchLatestHealthData(date: selectedDate)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundColor(Color.appButtonMain)

                        Spacer()

                        Text(formattedDate(selectedDate))
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(.horizontal)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                            }
                            Task {
                                await self.healthkitViewModel.fetchLatestHealthData(date: selectedDate)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(Color.appButtonMain)
                        .disabled(Calendar.current.isDateInToday(selectedDate))
                    }
                    .padding()

                    // MARK: Daily HRV trend

                    Section(header:
                        Text("dailyview_section_stress_trend_header")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                    ) {
                        VStack {
                            HStack {
                                Text("dailyview_section_stress_trend_graphlabel")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.appSenBody)

                                Spacer()

                                Image(systemName: "info.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        viewModel.toggleInfoSheet()
                                    }
                            }
                            .padding(.bottom, 10)

                            Divider()

                            HRVGraphView(dataPoints: self.healthkitViewModel.hrvDataPoints, mindfullPoints: self.healthkitViewModel.mindfulnessDataPoints)
                                .frame(height: self.healthkitViewModel.hrvDataPoints.isEmpty ? 100 : nil)
                                .frame(minHeight: self.healthkitViewModel.hrvDataPoints.isEmpty ? nil : 300, maxHeight: .infinity)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.appBackgroundGradientBottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                    }

                    // MARK: Latest HK data

                    if Calendar.current.isDateInToday(selectedDate) {
                        Section(header:
                            Text("dailyview_section_latest_readings_header")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                                .foregroundColor(.appTextDark)
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                        ) {
                            VStack {
                                LatestDataView()
                            }
                            .padding()
                            .background(Color.appBackgroundGradientBottom)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding([.horizontal])
                        }
                        .transition(.opacity)
                    }

                    // MARK: Recommended mindfulness practice

                    Section(header:
                        Text("dailyview_section_recommended_session")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                    ) {
                        VStack {
                            if let recommendedActivity = viewModel.recommendedActivity {
                                ActivityCardView().environmentObject(ActivityCardViewModel(activity: recommendedActivity))
                                    .padding([.horizontal])
                            } else {
                                Text("dailyview_section_recommended_loading")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .font(.appSenBody)
                                    .background(Color.appBackgroundGradientBottom)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
                .animation(.default, value: selectedDate)
            }
            .navigationTitle("home_header")
            .refreshable {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await self.healthkitViewModel.fetchLatestHealthData(date: selectedDate)
            }
        }
        .sheet(isPresented: $viewModel.showingInfoSheet) {
            DailyGraphSheetView()
                .presentationDetents([.large])
                .environmentObject(viewModel)
        }

        .onAppear {
            Task {
                await viewModel.resolveActivityForToday()
                await self.healthkitViewModel.fetchLatestHealthData(date: selectedDate)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
                case .active:
                    Task {
                        await self.healthkitViewModel.fetchLatestHealthData(date: selectedDate)
                    }

                case .inactive:
                    self.healthkitViewModel.clearHRVDataPoints()

                case .background:
                    self.healthkitViewModel.clearHRVDataPoints()

                @unknown default:
                    Logger.log("No bueno", .error)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

// MARK: Preview

#Preview {
    DailyView()
        .environmentObject(DailyViewModel.mock())
        .environmentObject(HealthkitViewModel.mock())
}
