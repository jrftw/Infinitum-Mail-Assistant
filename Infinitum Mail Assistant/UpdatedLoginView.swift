/*****************************************************************************
 MARK: UpdatedLoginView.swift
 Description:
   View that handles sign-in, sign-out, and shows the currently signed in user.
*****************************************************************************/

import SwiftUI

struct UpdatedLoginView: View {
    @ObservedObject var signInManager: GoogleSignInManager
    
    var body: some View {
        VStack(spacing: 20) {
            if signInManager.isLoggedIn {
                Text("You are signed in as:")
                    .font(.headline)
                Text(signInManager.userEmail)
                    .font(.subheadline)
                Button("Sign Out") {
                    signInManager.signOut()
                }
                .font(.headline)
            } else {
                Text("Sign in to continue")
                    .font(.title)
                GoogleSignInButton(signInManager: signInManager)
            }
        }
        .onAppear {
            signInManager.restorePreviousSignIn()
        }
        .padding()
    }
}
