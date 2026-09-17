//
//  LinkletApp.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import SwiftUI

@main
struct LinkletApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
//        Settings {
//            SettingsScreen()
//        }

        MenuBarExtra {
            MenuBarContent()
        } label: {
            MenubarLabel()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    public var browserService = BrowserService(browserConfigs: SupportedBrowserConfigs)
    lazy public var redirectManager = RedirectManager(browserService: browserService)
    lazy public var noticeManager = NoticeManager(vc: redirectManager, browserService: browserService)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        
        Task {
            // TODO: add error handling
            try? await NSWorkspace.shared.setDefaultApplication(
                at: Bundle.main.bundleURL,
                toOpenURLsWithScheme: "http"
            )
            try? await NSWorkspace.shared.setDefaultApplication(
                at: Bundle.main.bundleURL,
                toOpenURLsWithScheme: "https"
            )
        }
        noticeManager.setup()
        
        #if DEBUG
        if let testUrl = URL(string: "https://google.com")  {
            redirectManager.intake(url: testUrl)
        }
        #endif
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            redirectManager.intake(url: url)
        }
    }
}
