//
//  CategoriesView.swift
//  MindApp
//
//  Created by Daniel Davidík on 22.03.2024.
//

import SwiftUI

/// View for showing the categories of activities that are available with buttons leading to the ``ChooseSessionView`` of each of the categories
/// > Important: Needs to be provided with ``CategoriesViewModel`` as an environmentObject in order to function
///
/// Example usage:
/// ```swift
/// let cvm: CategoriesViewModel = CategoriesViewModel()
/// ...
/// CategoriesView()
///     .environmentObject(cvm)
/// ```
struct CategoriesView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            ScrollView {
                VStack {
                    VStack(spacing: 20) {
                        CategoryCardView(iconName: "wind", category: .breathing, description: "mind_breathing_desc")

                        CategoryCardView(iconName: "figure.mind.and.body", category: .meditation, description: "mind_meditation_desc")
                        ReflectionCardView()
                    }
                    .environmentObject(categoriesViewModel)
                    .padding()

                    Spacer()
                }
                .padding(.top, 60)
            }
            .navigationTitle("wellbeing_header")
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(CategoriesViewModel.mock())
    }
}
