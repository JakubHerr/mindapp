//
//  FormStepView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 15.02.2025.
//

import SwiftUI

struct FormStepView: View {
    @ObservedObject var step: FHIRItemBase
    
    private let rowHeight: CGFloat = 40
    
    @EnvironmentObject var vm: FormViewModel
    
    var isOnRound: Bool {
        step.linkId == vm.currStep.linkId
    }
            
    var body: some View {
        if let c = step as? FHIRChoiceItem {
            ChoiceItemView(choice: c, rowHeight: rowHeight)
                .environmentObject(vm)
        }
        else if let i = step as? FHIRIntegerItem {
            IntegerItemView(integer: i, rowHeight: rowHeight)
                .environmentObject(vm)
        }
        else if let b = step as? FHIRBooleanItem {
            BooleanItemView(boolean: b, rowHeight: rowHeight)
                .environmentObject(vm)
        }
        else if let t = step as? FHIRTextItem {
            VStack {
                VStack {
                    Text(t.text)
                        .foregroundStyle(Color.appTextBody)
                        .font(.appSenTitle)
                    Text(t.value)
                        .foregroundStyle(Color.appTextBody)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.appButtonOption)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .shadow(color: Color.green, radius: 5)
                        .shadow(color: Color.black, radius: 0, x: 5, y: 10)
                }
                .padding(.vertical)
                Spacer()
            }
            .padding()
        }
        else {
            Text("Hello world")
        }
    }
}

#Preview {
    let vm: FormViewModel = FormViewModel.mock
    FormStepView(step: vm.currStep)
        .environmentObject(vm)
}
