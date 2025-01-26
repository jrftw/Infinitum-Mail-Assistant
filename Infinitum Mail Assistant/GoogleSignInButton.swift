/*****************************************************************************
 MARK: GoogleSignInButton.swift
*****************************************************************************/

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: View {
    @ObservedObject var signInManager: GoogleSignInManager
    
    var body: some View {
        Button(action: {
            signInManager.signIn()
        }) {
            Text("Sign in with Google")
                .bold()
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.horizontal, 40)
    }
}
