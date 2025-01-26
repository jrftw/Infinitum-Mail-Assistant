/*****************************************************************************
 MARK: UpdatedInfinitum_Mail_AssistantApp.swift
 Description:
   Entry point of the app.
   Compatible with iOS 15.6+, macOS 11.5+, visionOS 2.0+.
*****************************************************************************/

import SwiftUI
import GoogleSignIn

@main
struct UpdatedInfinitum_Mail_AssistantApp: App {
    var body: some Scene {
        WindowGroup {
            UpdatedContentView()
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
