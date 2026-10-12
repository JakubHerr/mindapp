//
//  CustomBackButton.swift
//  MindApp
//
//  Created by Daniel Davidík on 24.03.2024.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    var title: LocalizedStringKey

    var requiresConfirmation: Bool = false
    
    @State private var showsConfirmation: Bool = false
    
    var body: some View {
        Button(action: {
            if requiresConfirmation {
                showsConfirmation = true
            }
            else {
                self.dismiss()
            }
        }) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.custom("Sen", size: 22))
                    .fontWeight(.bold)
            }
        }
        .alert("are_you_sure_alert", isPresented: $showsConfirmation) {
            Button("cancel_alert_option", role: .cancel) { }
            Button("yes_alert_option", role: .destructive) {
                self.dismiss()
            }
        }
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton(title: "Meditation")
    }
}
