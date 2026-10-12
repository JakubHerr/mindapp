//
//  FormStepViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 14.02.2025.
//

import Foundation

class FormViewModel: ObservableObject {
    
    
    @Published var steps: [FHIRItemBase]
    
    @Published var round: Int = 0
    
    @Published var finished: Bool = false
    
    var finish: ([FHIRItemBase]) async -> Void
    
    var currStep: FHIRItemBase {
        if steps.isEmpty {
            return FHIRBooleanItem(linkId: "empty", text: "empty")
        }
        if steps.count > round {
            return steps[round]
        }
        return steps[steps.count - 1]
    }
    
//    var progress: Double {
//        Double(Double(round) / Double(steps.count))
//    }
    
    var progress: Float {
        Float(round) / Float(steps.count)
    }
    
    init(steps: [FHIRItemBase], finish: @escaping ([FHIRItemBase]) -> Void) {
        self.steps = steps
        self.finish = finish
    }
    
    init() {
        self.steps = []
        self.finish = { _ in }
    }
    
    func addStep(step: FHIRItemBase) {
        self.steps.append(step)
    }
    
    func setSteps(steps: [FHIRItemBase]) {
        self.steps = steps
    }
    
    func setFinisher(finish: @escaping ([FHIRItemBase]) async -> Void) {
        self.finish = finish
    }
    
    func select<T>(option: T) {
        if let o = option as? Bool {
            if let q = currStep as? FHIRBooleanItem {
                q.selected = o
            }
            else {
                Logger.log("Incompatible option to the current step", .error)
                return
            }
        }
        else if let o = option as? Int {
            if let i = currStep as? FHIRIntegerItem {
                i.selected = o
            }
            else {
                Logger.log("Incompatible option to the current step", .error)
                return
            }
        }
        else if let o = option as? FHIRChoiceItemOption {
            if let c = currStep as? FHIRChoiceItem {
                if c.multipleChoice {
                    c.selected.append(o)
                }
                else {
                    c.selected = [o]
                }
            }
            else {
                Logger.log("Incompatible option to the current step", .error)
                return
            }
        }
        else {
            Logger.log("Incompatible option to any step", .error)
        }
    }
    
    func select<T>(option: T, for step: FHIRItemBase) {
        if let index = steps.firstIndex(where: { $0.linkId == step.linkId }) {
            if let o = option as? Bool {
                if let b = steps[index] as? FHIRBooleanItem {
                    b.selected = o
                }
                else {
                    Logger.log("Incompatible option to the given step", .error)
                    return
                }
            }
            else if let o = option as? Int {
                if let i = steps[index] as? FHIRIntegerItem {
                    i.selected = o
                }
                else {
                    Logger.log("Incompatible option to the given step", .error)
                    return
                }
            }
            else if let o = option as? FHIRChoiceItemOption {
                if let c = steps[index] as? FHIRChoiceItem {
                    if c.answerOption.contains(where: { $0.valueString == o.valueString }) {
                        if c.multipleChoice {
                            if let alreadySelected = c.selected.firstIndex(where: { $0.id == o.id }) {
                                c.selected.remove(at: alreadySelected)
                            }
                            else {
                                c.selected.append(o)
                            }
                        }
                        else {
                            c.selected = [o]
                        }
                    }
                    else {
                        Logger.log("Option not found in the answer options", .error)
                        return
                    }
                }
                else {
                    Logger.log("Incompatible option to the given step", .error)
                    return
                }
            }
            else {
                Logger.log("Incompatible option to any step", .error)
            }
        }
        else {
            Logger.log("No such step found", .error)
        }
    }
    
    public static var mock: FormViewModel {
        let s = FHIRTextItem(linkId: "1", text: "Summary", value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut augue eu tellus condimentum iaculis nec eget nisi. Mauris justo.", variableName: "Summary")
        
        let o1 = FHIRChoiceItemOption(valueString: "Option A")
        let o2 = FHIRChoiceItemOption(valueString: "Option B")
        let o3 = FHIRChoiceItemOption(valueString: "Option C")
        
        let s1 = FHIRChoiceItem(linkId: "2", text: "Choice question 1", answerOption: [o1, o2], selected: [o2])
        let s2 = FHIRBooleanItem(linkId: "3", text: "Are you okay?", selected: false)
        let s3 = FHIRIntegerItem(linkId: "4", text: "On a scale of one to ten, how drunk are you?", selected: 7)
        let s4 = FHIRChoiceItem(linkId: "5", text: "Multiple choice question 1", answerOption: [o1, o2, o3], selected: [o2, o3])
        return .init(steps: [s, s1, s2, s3, s4], finish: { _ in })
    }
    
    public func fetchFirstChoiceItem() -> FHIRChoiceItem? {
        for step in steps {
            if let choice = step as? FHIRChoiceItem {
                return choice
            }
        }
        return nil
    }
    
    public func fetchFirstIntegerItem() -> FHIRIntegerItem? {
        for step in steps {
            if let integer = step as? FHIRIntegerItem {
                return integer
            }
        }
        return nil
    }
    
    public func fetchFirstBoolItem() -> FHIRBooleanItem? {
        for step in steps {
            if let boolean = step as? FHIRBooleanItem {
                return boolean
            }
        }
        return nil
    }
}
