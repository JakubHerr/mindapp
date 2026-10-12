//
//  NotificationTimePickerSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 19.05.2024.
//

import SwiftUI

struct NotificationTimePickerSheet: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @State var time = Date()

    let headerLabel = NSLocalizedString("infosheet_mind_reminder_header", comment: "Header label")
    let buttonLabel = NSLocalizedString("infosheet_mind_reminder_button", comment: "Create button label")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: {
                    settingsViewModel.showingTimePicker = false
                    settingsViewModel.notificationMindfulReminderEnabled = false
                })

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: headerLabel, content: {
                        VStack {
                            DatePicker("", selection: $time, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .colorScheme(.dark)

                            Button(action: {
                                settingsViewModel.scheduleNotification(time: time)
                                settingsViewModel.showingTimePicker = false
                            }, label: {
                                HStack {
                                    Text(LocalizedStringKey(buttonLabel))
                                        .font(.appSenBody)
                                        .foregroundColor(.white)
                                }

                            })
                            .padding()
                            .background(Color.appTextDark)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    })
                }
            }
        }
        .onDisappear {
            if !UserDefaults.standard.bool(forKey: UserDefaultConstants.mindfulnessNotificationEnabled) {
                settingsViewModel.notificationMindfulReminderEnabled = false
            }
            settingsViewModel.showingTimePicker = false
        }
    }
}

#Preview {
    NotificationTimePickerSheet()
        .environmentObject(SettingsViewModel.mock())
}
