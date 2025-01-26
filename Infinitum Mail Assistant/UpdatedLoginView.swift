//
//  UpdatedLoginView.swift
//  Infinitum Mail Assistant
//
//  Created by Kevin Doyle Jr. on 1/24/25.
//


/*****************************************************************************
 MARK: UpdatedLoginView.swift
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