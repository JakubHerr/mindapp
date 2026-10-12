//
//  CustomSliderView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 02.02.2025.
//

import SwiftUI

struct CustomSliderView: View {
    
    var lg: LinearGradient
//    var lg: LinearGradient = LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .leading, endPoint: .trailing)
    
    @Binding var value: Double
    
    let minValue: Double
    
    let intMinValue: Int
    let intMaxValue: Int
    
    let intRange: ClosedRange<Int>
    
    let maxValue: Double
    
    let range: Int
    
    let step: Double?
    
    let color: Color
    
    let showTicks: Bool
    
    init(value: Binding<Double>, minValue: Double,
         maxValue: Double,
         color: Color = .black,
         showTicks: Bool = false,
         lg: LinearGradient = LinearGradient(gradient: Gradient(colors: [.red,.yellow,.green]), startPoint: .leading, endPoint: .trailing)) {
        self._value = value
        self.minValue = minValue
        self.intMinValue = Int(ceil(minValue))
        self.maxValue = maxValue
        self.intMaxValue = Int(floor(maxValue))
        self.intRange = intMinValue...intMaxValue
        self.range = intMaxValue - intMinValue + 1
        self.step = 1
        self.color = color
        self.showTicks = showTicks
        self.lg = lg
    }
    
    var body: some View {
            VStack {
                GeometryReader { geometry in
                    let spacing = geometry.size.width / CGFloat(max(range, 1))
                    
                    ZStack {
                        VStack(spacing: 5) {
                            ZStack(alignment: .center) {
                                if showTicks {
                                    HStack(spacing: 0) {
                                        ForEach(intMinValue...intMaxValue, id: \.self) { number in
                                            Text("|")
                                                .foregroundStyle(color)
                                                .frame(width: spacing)
                                                .offset(y: -1)
                                        }
                                    }                                    
                                }
                                lg
                                    .frame(width: geometry.size.width, height: 10)
                                    .cornerRadius(5)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                                
                                Circle()
                                    .foregroundStyle(Color.white)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: .black.opacity(0.2), radius: 8)
                                    .position(x: getOffset(geometry: geometry) + 15, y: 17)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { gesture in
                                                updateValue(with: gesture, in: geometry)
                                            }
                                    )
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(intMinValue...intMaxValue, id: \.self) { number in
                                    VStack {
                                        Text("\(number)")
                                            .foregroundStyle(color)
                                            .frame(width: spacing)
                                            .fontWeight(Int(value) == number ? .black : .regular)
//                                            .bold(Int(value) == number ? true : false)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 60)
            }
        }
                      
    func getOffset(geometry: GeometryProxy) -> CGFloat {
        let percentage = (value - minValue) / (maxValue - minValue)
        return percentage * (geometry.size.width - 30)
    }
    
    func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        if let rawStep = step {
            let rawValue = (gesture.location.x / geometry.size.width) * (maxValue - minValue) + minValue
            
            let steppedValue = round((rawValue - minValue) / rawStep) * rawStep + minValue
            
            value = min(max(steppedValue, minValue), maxValue)
        }
        else {
            let newValue = (gesture.location.x / geometry.size.width) * (maxValue - minValue) + minValue
            value = min(max(Double(newValue), minValue), maxValue)
        }
    }
}

#Preview {
    CustomSliderView(value: .constant(3.0), minValue: 0, maxValue: 15)
        .frame(width: .infinity, height: 20)
}
