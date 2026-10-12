//
//  SignInView.swift
//  MindApp
//
//  Created by Michael Slavev on 22.03.2024.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var email: String = ""
    @State var password: String = ""
        
    var body: some View {
        ZStack {
            BackgroundGradientView()
                
            VStack(spacing: 15) {
                Image("mind-app-transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .foregroundColor(.appButtonAccent)
                
                Text("auth_button_signin")
                    .padding([.horizontal], 16)
                    .padding(.top, -10)
                    .font(.appSenTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appButtonAccent)
                
                Text("auth_signin_desc")
                    .font(.appSenBody)
                    .padding([.leading, .trailing], 64)
                    .padding([.top], 4)
                    .foregroundColor(.appButtonAccent)
                    .multilineTextAlignment(.center)
                
                Spacer()
                    
                Text("auth_email_label")
                    .font(.appSenBody)
                    .foregroundColor(Color.appTextBody)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, -8)

                TextField("auth_email_text", text: $email)
                    .font(.appSenBody)
                    .padding(15)
                    .background(Color.appButtonAccent)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .shadow(radius: 5)
                    .padding(.bottom, -8)
                    
                Text("auth_password_label")
                    .font(.appSenBody)
                    .foregroundColor(Color.appTextBody)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, -8)
                
                SecureField("auth_password_text", text: $password)
                    .font(.appSenBody)
                    .padding(15)
                    .background(Color.appButtonAccent)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .shadow(radius: 5)
                    .padding(.bottom, 10)
                    
                Spacer()
                
                Button(action: {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }
                }, label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.appButtonAccent))
                    }
                    else {
                        Text("auth_button_signin")
                            .frame(maxWidth: .infinity)
                            .font(.appSenBody)
                            .bold(true)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.appTextDark)
                            .background(Color.appButtonAccent)
                            .cornerRadius(25)
                    }
                })
                .disabled(!authViewModel.validEmail(email: email))
                    
                Text(authViewModel.errorMessage)
                    .foregroundStyle(.red)
                    .bold(true)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(title: "back")
                    .foregroundStyle(Color.appButtonAccent)
            }
        }.dragGesture()
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthViewModel.mock())
    }
}
