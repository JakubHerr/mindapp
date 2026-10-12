//
//  BooleanItemView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 17.02.2025.
//

import SwiftUI

struct BooleanItemView: View {
    
    @ObservedObject var boolean: FHIRBooleanItem
    
    @EnvironmentObject var vm: FormViewModel
    
    var rowHeight: CGFloat
    
    var isOnRound: Bool {
        boolean.linkId == vm.currStep.linkId
    }
    
    var body: some View {
        VStack {
            Text(boolean.text)
                .font(.appSenTitle)
                .foregroundStyle(Color.appTextBody)
            List {
                self.makeButton(option: true)
                self.makeButton(option: false)
            }
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
//            .opacity(isOnRound ? 1 : 0.5)
//            .shadow(color: isOnRound ? Color.green : Color.red, radius: 20)
            .shadow(color: Color.black, radius: 0, x: 5, y: 10)

//            .border(.red)
        }
    }
    
    
    func makeButton(option: Bool) -> some View {
        Button(action: {
            vm.select(option: option, for: boolean)
        }) {
            HStack {
                Image(systemName: self.boolean.selected == option ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(Color.white)
                Text(option ? "Yes" : "No")
                    .foregroundColor(Color.white)
                    .font(.appSenBody)
            }
        }
        .listRowBackground(self.boolean.selected == option ? Color.appButtonOptionSelected : Color.appButtonOption)
        .frame(height: rowHeight)
        .disabled(!isOnRound)
    }
}

#Preview {
    let vm: FormViewModel = FormViewModel.mock
    let b = vm.fetchFirstBoolItem() ?? FHIRBooleanItem(linkId: "1", text: "Are ya okay bruh?", selected: false)
    ZStack {
        Color.black.ignoresSafeArea()
        BooleanItemView(boolean: b, rowHeight: 40)
            .environmentObject(vm)
    }
}
