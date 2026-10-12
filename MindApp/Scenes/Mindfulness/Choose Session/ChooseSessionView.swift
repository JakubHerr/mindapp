//
//  ChooseSessionView.swift
//  MindApp
//
//  Created by Daniel Davidík on 22.03.2024.
//

import SwiftUI

/// View for showing all activities in a specified category
/// > Important: Needs to be provided with ``CategoriesViewModel`` and ``ChooseSessionViewModel`` as environment objects in order to function
///
/// Example definition:
/// ```swift
///let cvm: CategoriesViewModel = CategoriesViewModel()
///let csvm: ChooseSessionViewModel = ChooseSessionViewModel()
///...
///ChooseSessionView(category)
///     .environmentObject(cvm)
///     .environmentObject(csvm)
///```
struct ChooseSessionView: View {
    var category: MindfulnessCategory

    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var viewModel: ChooseSessionViewModel

    var filteredActivities: [Activity] {
        categoriesViewModel.getFilteredActivities(category: category, type: categoriesViewModel.selectedType)
    }

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.mindfulnessTypes, id: \.name) { mindfulnessType in
                            TypeView(type: mindfulnessType)
                                .onTapGesture {
                                    categoriesViewModel.selectedType = mindfulnessType.name
                                }
                        }
                    }
                }
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(filteredActivities, id: \.id) { activity in
                            ActivityCardView().environmentObject(ActivityCardViewModel(activity: activity))
                        }
                    }
                }
            }
            .padding()
        }
        .onDisappear {
            categoriesViewModel.selectedType = "all"
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: category.localized).foregroundStyle(Color.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .dragGesture()
    }
}

struct ChooseSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSessionView(category: .breathing)
            .environmentObject(CategoriesViewModel())
            .environmentObject(ChooseSessionViewModel())
    }
}
