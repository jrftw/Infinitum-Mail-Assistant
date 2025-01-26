/*****************************************************************************
 MARK: GoogleSignInManager.swift
 Description:
   Uses GoogleSignIn 6.x+ with GIDConfiguration for sign-in.
   Then optionally adds additional Gmail scopes after sign-in.
   Fully removes extra/hint arguments to match the valid signature:
     signIn(with: GIDConfiguration, presenting: UIViewController, completion: ...)
   Ensures no leftover references to user.user or invalid method calls.
   Compatible with iOS 15.6+, macOS 11.5+, visionOS 2.0+.
*****************************************************************************/

import SwiftUI
import GoogleSignIn

class GoogleSignInManager: ObservableObject {
    // MARK: Published State
    @Published var isLoggedIn = false
    @Published var userEmail = ""
    
    // MARK: Client ID & Additional Scopes
    private let clientID = "105380332603-jbevkbsd2gp6p63lrv7k54rki0kcoqtq.apps.googleusercontent.com"
    private let extraScopes = [
        "https://www.googleapis.com/auth/gmail.readonly",
        "https://www.googleapis.com/auth/gmail.modify"
    ]
    
    // MARK: signIn
    func signIn() {
        let config = GIDConfiguration(clientID: clientID)
        
        // Acquire the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController
        else { return }
        
        // Call signIn(with:config,presenting:completion:)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
            if let _ = error {
                return
            }
            guard let googleUser = user else {
                return
            }
            // Request extra Gmail scopes after sign-in
            googleUser.addScopes(self.extraScopes, presenting: rootVC) { _ in
                let profile = googleUser.profile
                self.userEmail = profile?.email ?? ""
                self.isLoggedIn = true
            }
        }
    }
    
    // MARK: signOut
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isLoggedIn = false
        userEmail = ""
    }
    
    // MARK: restorePreviousSignIn
    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let _ = error {
                self.isLoggedIn = false
                self.userEmail = ""
                return
            }
            guard let googleUser = user else {
                self.isLoggedIn = false
                self.userEmail = ""
                return
            }
            let profile = googleUser.profile
            self.userEmail = profile?.email ?? ""
            self.isLoggedIn = true
        }
    }
}
