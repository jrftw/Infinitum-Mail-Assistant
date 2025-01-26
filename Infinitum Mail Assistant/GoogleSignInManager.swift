/*****************************************************************************
 MARK: GoogleSignInManager.swift
 Description:
   Uses GoogleSignIn with GIDConfiguration for sign-in. Updated for
   GoogleSignIn (7.x or newer), where GIDSignInResult doesn't have a
   'profile' property but its 'user' does.
   Compatible with iOS 15.6+, macOS 11.5+, visionOS 2.0+.
*****************************************************************************/

import SwiftUI
import GoogleSignIn
import os.log

class GoogleSignInManager: ObservableObject {
    // MARK: - Published State
    @Published var isLoggedIn = false
    @Published var userEmail = ""
    
    // MARK: - Client ID & Additional Scopes
    private let clientID = "105380332603-jbevkbsd2gp6p63lrv7k54rki0kcoqtq.apps.googleusercontent.com"
    private let extraScopes = [
        "https://www.googleapis.com/auth/gmail.readonly",
        "https://www.googleapis.com/auth/gmail.modify"
    ]
    
    // MARK: - signIn
    func signIn() {
        os_log("Attempting sign-in...", log: OSLog.default, type: .info)
        
        // Assign the configuration
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Acquire the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController
        else {
            os_log("Failed to get root ViewController.", log: OSLog.default, type: .error)
            return
        }
        
        // Invoke signIn with the new API
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let err = error {
                os_log("Sign-in error: %@", log: OSLog.default, type: .error, err.localizedDescription)
                return
            }
            guard let signInResult = signInResult else {
                os_log("No result returned after sign-in.", log: OSLog.default, type: .error)
                return
            }
            
            // Request extra Gmail scopes
            signInResult.user.addScopes(self.extraScopes, presenting: rootVC) { updatedUser, scopeError in
                if let scopeError = scopeError {
                    os_log("Scope request error: %@", log: OSLog.default, type: .error, scopeError.localizedDescription)
                    return
                }
                guard let userWithScopes = updatedUser else {
                    os_log("Failed to apply additional scopes.", log: OSLog.default, type: .error)
                    return
                }
                
                // GIDSignInResult has 'user', which has 'profile'
                let profile = userWithScopes.profile
                self.userEmail = profile?.email ?? ""
                self.isLoggedIn = true
                os_log("Sign-in successful. Email: %@", log: OSLog.default, type: .info, self.userEmail)
            }
        }
    }
    
    // MARK: - signOut
    func signOut() {
        os_log("Signing out...", log: OSLog.default, type: .info)
        GIDSignIn.sharedInstance.signOut()
        isLoggedIn = false
        userEmail = ""
        os_log("Signed out successfully.", log: OSLog.default, type: .info)
    }
    
    // MARK: - restorePreviousSignIn
    func restorePreviousSignIn() {
        os_log("Attempting to restore previous sign-in...", log: OSLog.default, type: .info)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let err = error {
                os_log("Restore sign-in error: %@", log: OSLog.default, type: .error, err.localizedDescription)
                self.isLoggedIn = false
                self.userEmail = ""
                return
            }
            guard let restoredUser = user else {
                os_log("No user returned from restore.", log: OSLog.default, type: .error)
                self.isLoggedIn = false
                self.userEmail = ""
                return
            }
            
            let profile = restoredUser.profile
            self.userEmail = profile?.email ?? ""
            self.isLoggedIn = true
            os_log("Previous sign-in restored. Email: %@", log: OSLog.default, type: .info, self.userEmail)
        }
    }
}
