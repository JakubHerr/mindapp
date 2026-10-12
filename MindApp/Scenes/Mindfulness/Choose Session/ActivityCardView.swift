//
//  ActivityCardView.swift
//  MindApp
//
//  Created by Daniel Davidík on 29.03.2024.
//

import SwiftUI

/// Card button view for a specific activity
/// > Important: Needs to be provided with ``ActivityCardViewModel`` as an environmentObject in order to function
///
/// Example usage:
/// ```swift
/// let acvm: ActivityCardViewModel = ActivityCardViewModel()
/// ...
/// ActivityCardView()
///     .environmentObject(acvm)
/// ```
struct ActivityCardView: View {
    @EnvironmentObject var viewModel: ActivityCardViewModel

    var body: some View {
        ZStack {
            NavigationLink(destination: SessionView().environmentObject(SessionViewModel(activity: viewModel.activity)).toolbar(.hidden, for: .tabBar)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: viewModel.activity.imageUrl)
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .padding(.trailing, 0)
                            .padding(.leading, 16)

                        VStack(alignment: .leading) {
                            Text(viewModel.getDurationText(for: viewModel.activity))
                                .font(.custom("Sen", size: 12))

                            HStack {
                                Text(viewModel.activity.localization[0].title)
                                    .font(.custom("Sen", size: 20))
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 22))
                            }
                            .padding(.vertical, 1)

                            Text(viewModel.activity.localization[0].description)
                                .font(.appSenBody)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                    }
                }
                .background(Color.appBackgroundGradientBottom)
                .cornerRadius(10)
            }
        }
    }
}

struct ActivityCardView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCardView()
            .environmentObject(ActivityCardViewModel.mock())
    }
}
