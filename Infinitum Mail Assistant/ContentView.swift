/*****************************************************************************
 MARK: UpdatedContentView.swift
*****************************************************************************/

import SwiftUI
import os.log

struct UpdatedContentView: View {
    @StateObject private var signInManager = GoogleSignInManager()
    @State private var showDuplicates = false
    @State private var showUnsubscribe = false
    
    var body: some View {
        NavigationView {
            if !signInManager.isLoggedIn {
                UpdatedLoginView(signInManager: signInManager)
            } else {
                VStack(spacing: 20) {
                    Text("Infinitum Mail Assistant")
                        .font(.title)
                    Button("Check for Duplicates") {
                        showDuplicates = true
                    }
                    .font(.headline)
                    .sheet(isPresented: $showDuplicates) {
                        DuplicateListView(userEmail: signInManager.userEmail)
                    }
                    
                    Button("Mass Unsubscribe") {
                        showUnsubscribe = true
                    }
                    .font(.headline)
                    .sheet(isPresented: $showUnsubscribe) {
                        UnsubscribeView(userEmail: signInManager.userEmail)
                    }
                }
                .padding()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
