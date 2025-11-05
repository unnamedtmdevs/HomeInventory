//
//  HomeInventoryApp.swift
//  HomeInventory
//
//  Created by Дионисий Коневиченко on 05.11.2025.
//

import SwiftUI

@main
struct HomeInventoryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
