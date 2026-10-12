//
//  IntegerItemView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 16.02.2025.
//

import SwiftUI

struct IntegerItemView: View {
    @ObservedObject var integer: FHIRIntegerItem
    
    @EnvironmentObject var vm: FormViewModel
    
    var rowHeight: CGFloat
    
    var isOnRound: Bool {
        integer.linkId == vm.currStep.linkId
    }
    
    @State private var selected: Double
    
    init(integer: FHIRIntegerItem, rowHeight: CGFloat) {
        self.integer = integer
        self.rowHeight = rowHeight
        if let preset = integer.selected {
            self.selected = Double(preset)
//            print(preset)
        }
        else {
            self.selected = 1
        }
    }
    
    var body: some View {
        VStack {
            Text(integer.text)
                .font(.appSenTitle)
                .foregroundStyle(Color.appTextBody)
            VStack {
                CustomSliderView(value: $selected, minValue: 1, maxValue: 10, color: .white, showTicks: false, lg: LinearGradient(gradient: Gradient(colors: [.appButtonMain]), startPoint: .leading, endPoint: .trailing))
                    .onChange(of: selected) { newValue in
                        integer.selected = Int(newValue)
                    }
//                    .opacity(isOnRound ? 1 : 0.5)
//                    .shadow(color: isOnRound ? Color.green : Color.red, radius: 20)
                    .disabled(!isOnRound)
            }
            .padding()
            .background(Color.appButtonOption)
            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .shadow(color: Color.green, radius: 5)
            .shadow(color: Color.black, radius: 0, x: 5, y: 10)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let vm: FormViewModel = FormViewModel.mock
    let integer: FHIRIntegerItem = vm.fetchFirstIntegerItem() ?? FHIRIntegerItem(linkId: "1", text: "How good are you?", selected: 4)
    ZStack {
        Color.black.ignoresSafeArea()
        IntegerItemView(integer: integer, rowHeight: 40)
            .environmentObject(vm)
    }
}
