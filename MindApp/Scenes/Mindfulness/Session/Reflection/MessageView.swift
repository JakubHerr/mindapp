//
//  RequestResponseView.swift
//  llamapoc
//
//  Created by Jan Gutwirth on 25.09.2024.
//

import SwiftUI

struct MessageView: View {
    @StateObject var message: Message
    
    var body: some View {
        HStack {
            if message.getIsRequest() {
                Spacer()
            }
            if let textMsg = message as? TextMessage {
                Text(textMsg.getText())
                    .padding()
                    .background(textMsg.getIsRequest() ? Color.appBackgroundGreenMain : Color.cyan)
                    .foregroundColor(textMsg.getIsRequest() ? Color.appTextBody : Color.black)
                    .cornerRadius(15)
                    .shadow(radius: 10)
            }
            else if let questionaire = message as? Questionnaire {
                ReflectionQuestionComboBoxView()
                    .environmentObject(questionaire)
            }
            if !message.getIsRequest() {
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    MessageView(message: TextMessage(text: "Hello World", isRequest: false))
    MessageView(message: TextMessage(text: "Hello World", isRequest: true))
    MessageView(message: Questionnaire.mock)
}
