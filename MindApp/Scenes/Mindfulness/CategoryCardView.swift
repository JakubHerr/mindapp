//
//  CategoryCardView.swift
//  MindApp
//
//  Created by Daniel Davidík on 22.03.2024.
//

import SwiftUI

/// View containing a button leading to the ``ChooseSessionView`` for the selected category
/// > Important: Needs to be provided with ``CategoriesViewModel`` as an environmentObject in order to function
///
/// Example usage:
/// ```swift
/// let cvm: CategoriesViewModel = CategoriesViewModel()
/// ...
/// CategoryCardView(iconName, category, description)
///     .environmentObject(cvm)
/// ```
struct CategoryCardView: View {
    var iconName: String
    var category: MindfulnessCategory
    var description: LocalizedStringKey

    @EnvironmentObject var categoriesViewModel: CategoriesViewModel

    var body: some View {
        NavigationLink(destination: ChooseSessionView(category: category).environmentObject(categoriesViewModel)) {
            VStack {
                HStack {
                    Text(category.localized)
                        .font(.appSenTitle)
                        .foregroundStyle(Color.white)
                        .textCase(.uppercase)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding()

                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.green)

                Text(description)
                    .font(.appSenBody)
                    .foregroundColor(.appTextBody)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.appButtonMain)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct CategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCardView(iconName: "wind", category: .breathing, description: "A series of guided breathing exercises to help you relax.")
            .environmentObject(CategoriesViewModel.mock())
    }
}
