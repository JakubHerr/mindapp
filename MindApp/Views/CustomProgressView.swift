//
//  CustomProgressView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 12.04.2025.
//

import SwiftUI

struct CustomProgressView: View {
    
    var step: Float
        
    let totalSteps: Float
    
    private let checkpointSize: CGFloat
    
    let color: Color
    
    init(step: Float, totalSteps: Float, color: Color = .black) {
        self.step = step
        self.totalSteps = totalSteps
        self.checkpointSize = 10
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                ProgressView(value: step, total: totalSteps)
                    .tint(color)
                checkpoints
            }
            .frame(height: 10)
//            .border(Color.red)
//            Text("\(Int(step/totalSteps * 100))%_there")
        }
//        .padding()
    }
    
    var checkpoints: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width - (CGFloat(totalSteps) * checkpointSize)
            let spacing = totalSteps > 1 ? availableWidth / CGFloat(totalSteps) : 0
            HStack(spacing: spacing) {
                ForEach(0...Int(totalSteps), id: \.self) { val in
                    Circle()
                        .fill(val == 0 ? Color.clear : val <= Int(step) ? color : Color.gray)
                        .frame(width: checkpointSize, height: checkpointSize)
                }
            }
//            .onAppear {
//                print(spacing)
//                print(proxy.size.width)
//            }
//            .offset(x: CGFloat(proxy.size.width) / CGFloat(totalSteps))
            .frame(width: proxy.size.width)
        }
//        .border(.red)
    }
}

#Preview {
    CustomProgressView(step: 3, totalSteps: 5)
}
