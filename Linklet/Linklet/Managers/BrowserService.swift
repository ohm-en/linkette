//
//  BrowserService.swift
//  Linklet
//
//  Created by Chef on 8/23/26.
//

import SwiftUI
internal import UniformTypeIdentifiers

/**
 * Provides a source of truth for current available browsers and their profiles. Consumer can treat the published values as if they the latest available.
 */
@Observable
class BrowserService {
    let browserConfigs: [BrowserConfig]
    
    var browsers: [BaseBrowser] = []
    
    init(browserConfigs: [BrowserConfig]) {
        self.browserConfigs = browserConfigs
        
        self.browsers = browserConfigs.compactMap { config in
            if isAppInstalled(bundleID: config.id) {
                print("Found \(config.id)")
                return config.makeBrowserInstance()
            }
            
            return nil
        }
    }
    
    // TODO: timer based or keep external?
    
    func getBrowserProfile(for browserName: String, named profile: String) -> BrowserProfile? {
        guard let browser: any Browser = browsers.first(where: { $0.id == browserName }) else {
            // TODO: better handle path
            print("FAILED TO FIND BROWSER")
            return nil
        }
        
        let browserProfile: BrowserProfile? = browser.getProfile(with: profile)
        return browserProfile
        
        // TODO: if not found, try again after refreshing
    }
    
    func getDefaultProfile() -> BrowserProfile? {
        if let person = browsers.first?.profiles.first(where: { $0.name == "Profile 1" }) {
            return person // TOOD: TEMP for testing. Just sets the default b rowser to one of mine
        }
        return browsers.first?.profiles.first
    }
    
    func refresh() {
        for browser in browsers {
            let result = browser.retrieveProfiles()
            // TODO: check result
        }
    }
}
