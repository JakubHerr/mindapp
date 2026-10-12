//
//  ErrorPopup.swift
//  MindApp
//
//  Created by Jan Gutwirth on 03.03.2025.
//

import SwiftUI

struct ErrorPopup: View {
        
    @Binding var error: DifyError?
    
    @Environment(\.dismiss) var dismiss
    
    var isPermanent: Bool = false
    
    @State private var progress: CGFloat = 1.0
    
    var body: some View {
        VStack {
            HStack {
                if let err = error {
                    Text(err.localizedDescription)
                        .foregroundStyle(Color.appTextDark)
                }
                else {
                    Text("An error occured")
                }
                Spacer()
                Button {
                    if error != nil {
                        error = nil
                    }
                    dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .font(.title)
                        .foregroundStyle(Color.black)
                }
            }
            
            reverseProgressBar
        }
        .padding()
        .background(Color.appAccentBright)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .green, radius: 5)
        .padding()
    }
    
    var reverseProgressBar: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: geometry.size.width * progress, height: 2)
                .foregroundStyle(Color.appAccentGreenDark)
                .onAppear {
                    if !isPermanent {
                        withAnimation(.linear(duration: 5)) {
                            progress = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if error != nil {
                                error = nil
                            }
                            dismiss()
                        }
                    }
                }
        }
        .frame(height: 2)
    }
}

#Preview {
    ErrorPopup(error: .constant(DifyError.invalidResponse))
}
