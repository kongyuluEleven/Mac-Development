//
//  KMutiPlatTest01App.swift
//  Shared
//
//  Created by kongyulu on 2020/9/9.
//

import SwiftUI

@available(OSX 11.0, *)
@main
struct KMutiPlatTest01App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
