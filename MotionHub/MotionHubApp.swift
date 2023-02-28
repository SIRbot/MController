//
//  MotionHubApp.swift
//  MotionHub
//
//  Created by Jerry Rong on 2023/2/2.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

@main
struct MotionHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
