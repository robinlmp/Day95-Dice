//
//  Day95_DiceApp.swift
//  Day95-Dice
//
//  Created by Robin Phillips on 28/08/2021.
//

import SwiftUI

@main
struct Day95_DiceApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
