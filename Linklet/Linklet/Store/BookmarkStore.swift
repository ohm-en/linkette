//
//  store.swift
//  Linklet
//
//  Created by Chef on 9/10/26.
//

import SwiftData

// TODO: unsure I like this format
@MainActor
enum DataStack {
    static let container: ModelContainer = {
        do {
            #if DEBUG
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            #else
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            #endif
            return try ModelContainer(for: Bookmark.self, configurations: config)
        } catch {
            print(error)
            fatalError("Failed to load ModelContainer.")
        }
    }()

    static var mainContext: ModelContext { container.mainContext }
}
