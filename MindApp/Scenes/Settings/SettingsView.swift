//
//  SettingsView.swift
//  MindApp
//
//  Created by Michael Slavev on 23.03.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    private let profileHeaderText = NSLocalizedString("settings_section_profile", comment: "Section Profile - header label")
    private let logoutText = NSLocalizedString("settings_profile_logout", comment: "Section Profile - logout label")
    private let languageText = NSLocalizedString("settings_profile_language", comment: "Section Profile - language label")
    private let stressReminderText = NSLocalizedString("settings_profile_stress_reminder", comment: "Section Profile - stress reminder label")
    private let dailyReminderText = NSLocalizedString("settings_profile_daily_reminder", comment: "Section Profile - daily reminder label")

    private let faqHeaderText = NSLocalizedString("settings_section_faq", comment: "Section FAQ - header label")
    private let aboutHrvText = NSLocalizedString("settings_faq_abouthrv", comment: "Section FAQ - About HRV")
    private let measuringStressText = NSLocalizedString("settings_faq_measuringstress", comment: "Section FAQ - How is stressed measured")
    private let howOfterText = NSLocalizedString("settings_faq_howoften", comment: "Section FAQ - How often")

    // MARK: - Building View

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            ScrollView {
                VStack {
                    // MARK: Profile section

                    Section(header:
                        Text(profileHeaderText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                    ) {
                        VStack {
                            // SignOut
                            makeSectionButton(title: logoutText, iconName: "rectangle.portrait.and.arrow.right") {
                                await authViewModel.signoutUser()
                            }

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            // Language
                            makeSectionButton(title: languageText, iconName: "globe") {
                                await settingsViewModel.openAppSettings()
                            }

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            // Stress notifications
                            makeNotificationToggle(
                                title: stressReminderText,
                                isOn: $settingsViewModel.notificationStressEnabled
                            ) {
                                Task {
                                    await settingsViewModel.toggleStressNotifications()
                                }
                            }

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            // Scheduled mindfulness notification
                            makeNotificationToggle(
                                title: dailyReminderText,
                                isOn: $settingsViewModel.notificationMindfulReminderEnabled
                            ) {
                                if settingsViewModel.notificationMindfulReminderEnabled {
                                    settingsViewModel.showingTimePicker = true
                                } else {
                                    settingsViewModel.unscheduleNotification()
                                }
                            }
                            .sheet(isPresented: $settingsViewModel.showingTimePicker) {
                                NotificationTimePickerSheet()
                                    .presentationDetents([.medium])
                                    .environmentObject(settingsViewModel)
                            }
                        }
                        .padding()
                        .background(Color.appBackgroundGradientBottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                    }

                    // MARK: FAQ

                    Section(header:
                        Text(faqHeaderText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.appSenBody)
                            .foregroundColor(.appTextDark)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                    ) {
                        VStack {
                            // What is HRV
                            makeSectionButton(title: aboutHrvText) {
                                await settingsViewModel.toggleAboutHrvInfoSheet()
                            }
                            .sheet(isPresented: $settingsViewModel.showingAboutHrvInfoSheet) {
                                FaqAboutHrvInfoSheet()
                                    .presentationDetents([.large])
                                    .environmentObject(settingsViewModel)
                            }

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            // How me measure stress
                            makeSectionButton(title: measuringStressText) {
                                await settingsViewModel.toggleStressMeasurementInfoSheet()
                            }
                            .sheet(isPresented: $settingsViewModel.showingStressMeasurementInfoSheet) {
                                FaqStressMeasureInfoSheet()
                                    .presentationDetents([.large])
                                    .environmentObject(settingsViewModel)
                            }

                            Divider()
                                .overlay(Color.appBackgroundGradientTop)
                                .padding(3)

                            // How often is HRV collected
                            makeSectionButton(title: howOfterText) {
                                await settingsViewModel.toggleHowOftenInfoSheet()
                            }
                            .sheet(isPresented: $settingsViewModel.showingHowOftenInfoSheet) {
                                FaqHowOftenInfoSheet()
                                    .presentationDetents([.large])
                                    .environmentObject(settingsViewModel)
                            }
                        }
                        .padding()
                        .background(Color.appBackgroundGradientBottom)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                    }
                }
            }
        }
        .navigationTitle("settings_header")
    }

    // MARK: Functions

    // Danamic clickable settings row
    func makeSectionButton(title: String, iconName: String = "", action: @escaping @Sendable () async -> Void) -> some View {
        Button(action: {
            Task {
                await action()
            }
        }, label: {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.appSenBody)
                    .foregroundColor(.white)

                Spacer()

                if !iconName.isEmpty {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(width: 20, height: 20)
                }
            }

        })
    }

    // Reusable notification toggle with date picker
    func makeNotificationToggle(title: String, isOn: Binding<Bool>, action: @escaping () -> Void) -> some View {
        VStack {
            Toggle(isOn: isOn) {
                Text(title)
                    .font(.appSenBody)
                    .foregroundColor(.white)
            }
            .frame(height: 20)
            .onChange(of: isOn.wrappedValue) { _ in
                action()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel.mock())
        .environmentObject(SettingsViewModel.mock())
}
