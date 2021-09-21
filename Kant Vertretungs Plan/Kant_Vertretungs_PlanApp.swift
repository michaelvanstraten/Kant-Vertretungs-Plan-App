//
//  Kant_Vertretungs_PlanApp.swift
//  Kant Vertretungs Plan
//
//  Created by Michael Van straten on 15.09.21.
//

import SwiftUI

@main
struct Kant_Vertretungs_PlanApp: App {
    let persistenceController = PersistenceController.shared
    let kantapp = VertretungsPlanApp()
    var body: some Scene {
        WindowGroup {
            ContentView(KantApp: kantapp)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
