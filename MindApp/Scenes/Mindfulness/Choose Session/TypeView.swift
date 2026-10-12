//
//  CategoryTabView.swift
//  MindApp
//
//  Created by Daniel Davidík on 25.03.2024.
//

import SwiftUI

/// View for showing a specific type of activity to be selected / filtered
/// > Important: Needs to be provided with ``CategoriesViewModel`` as an environmentObject to function
///
/// Example usage:
/// ```swift
/// let cvm: CategoriesViewModel = CategoriesViewModel()
/// ...
/// TypeView(type)
///     .environmentObject(cvm)
/// ```
struct TypeView: View {
    var type: Activity.MindfulnessType

    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @State private var isTapped = false

    var body: some View {
        VStack {
            Image(systemName: type.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding()
                .background(categoriesViewModel.selectedType == type.name ? Color.appBackgroundGradientTop : Color.appBackgroundGradientBottom)
                .cornerRadius(10)
                .scaleEffect(isTapped ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isTapped)

            Text(type.localization[0].name)
                .font(.custom("Sen", size: 12))
                .foregroundStyle(Color.appTextDark)
                .textCase(.uppercase)
        }
        .onTapGesture {
            isTapped = true
            categoriesViewModel.selectType(type.name)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTapped = false
            }
        }
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        let mockLocalization = Activity.MindfulnessType.MindfulnessLocalization(locale: "en", name: "Calm")
        let mockMindfulnessType = Activity.MindfulnessType(id: 1, name: "calm", iconName: "leaf", localization: [mockLocalization])
        return TypeView(type: mockMindfulnessType)
            .environmentObject(CategoriesViewModel.mock())
    }
}
