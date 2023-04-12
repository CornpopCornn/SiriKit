//
//  SiriKitApp.swift
//  SiriKit
//
//  Created by Xcode ServerSdr13579! on 11/04/2023.
//

import SwiftUI


@main
struct SiriKitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
