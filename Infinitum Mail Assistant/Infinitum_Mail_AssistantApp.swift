//
//  Infinitum_Mail_AssistantApp.swift
//  Infinitum Mail Assistant
//
//  Created by Kevin Doyle Jr. on 1/24/25.
//

import SwiftUI
import SwiftData

@main
struct Infinitum_Mail_AssistantApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
