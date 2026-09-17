//
//  SettingsView.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import SwiftUI

//struct SettingsScreen: View {
//    var body: some View {
//        Form {
//            // TODO: update to run for each browser in browser service
//            // TODO: clean up
//            Button("Choose Brave Folder") {
//                print(">>> button tapped")
//                let chromeSupportURL = FileManager.default
//                    .homeDirectoryForCurrentUser
//                    .appendingPathComponent("Library/Application Support/BraveSoftware/Brave-Browser", isDirectory: true)
//                let panel = NSOpenPanel()
//                panel.directoryURL = chromeSupportURL
//                panel.canChooseDirectories = true
//                panel.canChooseFiles = false
//                panel.message = "Grant access to Chrome's data folder to manage profiles"
//                panel.prompt = "Grant Access"
//                if panel.runModal() == .OK, let url = panel.url {
//                    let ok = url.startAccessingSecurityScopedResource()
//                    defer { url.stopAccessingSecurityScopedResource() }
//                    print("scope started:", ok)
//                    let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path)
//                    print("contents:", contents ?? "nil")
//                    if let bookmark = try? url.bookmarkData(
//                        options: .withSecurityScope,
//                        includingResourceValuesForKeys: nil,
//                        relativeTo: nil
//                    ) {
//                        UserDefaults.standard.set(bookmark, forKey: "chromeDir")
//                    }
//                }
//            }
//        }
//    }
//}
