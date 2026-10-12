//
//  ChoiceItemView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 16.02.2025.
//

import SwiftUI

struct ChoiceItemView: View {
    @ObservedObject var choice: FHIRChoiceItem
    
    @EnvironmentObject var vm: FormViewModel
    
    var rowHeight: CGFloat
    
    var isOnRound: Bool {
        choice.linkId == vm.currStep.linkId
    }
    
    private func isSelected(option: FHIRChoiceItemOption) -> Bool {
        return choice.selected.contains(where: { $0.id == option.id })
    }
    
    var body: some View {
        VStack {
            Text(choice.text)
                .font(.appSenTitle)
                .foregroundStyle(Color.appTextBody)
            List {
                ForEach(choice.answerOption, id: \.id) { option in
                    self.makeButton(option: option)
                }
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
    
    func makeButton(option: FHIRChoiceItemOption) -> some View {
        Button(action: {
            vm.select(option: option, for: choice)
        }) {
            HStack {
                if choice.multipleChoice {
                    Image(systemName: self.isSelected(option: option) ? "multiply.square" : "square")
                        .foregroundStyle(Color.white)
                }
                else {
                    Image(systemName: self.isSelected(option: option) ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(Color.white)
                }
                Text(option.valueString)
                    .foregroundColor(Color.white)
                    .font(.appSenBody)
            }
        }
        .listRowBackground(self.isSelected(option: option) ? Color.appButtonOptionSelected : Color.appButtonOption)
        .frame(height: rowHeight)
        .disabled(!isOnRound)
    }
}

#Preview {
    let vm: FormViewModel = FormViewModel.mock
    let o1 = FHIRChoiceItemOption(valueString: "Option A")
    let o2 = FHIRChoiceItemOption(valueString: "Option B")
    let choice: FHIRChoiceItem = vm.fetchFirstChoiceItem() ?? FHIRChoiceItem(linkId: "1", text: "Choice", answerOption: [o1, o2], selected: [o2])
    ZStack {
        Color.black.ignoresSafeArea()
        ChoiceItemView(choice: choice, rowHeight: 40)
            .environmentObject(vm)
    }
}
