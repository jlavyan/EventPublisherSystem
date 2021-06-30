//
//  EventPublisherSystemApp.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import SwiftUI
import CoreData
@main
struct EventPublisherApp: App {
    private let controller = PersistenceController.shared

    var viewContext: NSManagedObjectContext {
        controller.container.viewContext
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
