//
//  Menubar.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import SwiftUI

struct MenuBarContent: View {
    var body: some View {
        #if DEBUG
        Text("Linkette (testing)")
        #else
        Text("Linkette")
        #endif
        SettingsLink {
            Label("Settings", systemImage: "gearshape")
        }
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}

struct MenubarLabel: View {
    var body: some View {
        Image(systemName: "doc.on.clipboard")
    }
}
