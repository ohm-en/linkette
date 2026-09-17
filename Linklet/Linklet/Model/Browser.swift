//
//  Browser.swift
//  Linklet
//
//  Created by Chef on 8/23/26.
//

import Foundation
import AppKit
internal import UniformTypeIdentifiers

struct BrowserProfile: Identifiable, Hashable {
    var id: String // string used to access profile (changes per BrowserType)
    let name: String // display
    let browser: BaseBrowser // associated to profiel
    
    func launch(url: URL) {
        browser.launch(profile: self, url: url)
    }
}


protocol Browser: Hashable {
    func getProfile(with: String) -> BrowserProfile?
    func retrieveProfiles() -> Result<[BrowserProfile], BrowserError>
}

// Defines browsers that are available and ready for use.
class BaseBrowser: Browser {
    static func == (lhs: BaseBrowser, rhs: BaseBrowser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String
    var name: String // displayed
    var dataDirectory: String
    var profiles: [BrowserProfile]
    
    init(id: String, name: String, dataDirectory: String, profiles: [BrowserProfile]) {
        self.id = id
        self.name = name
        self.dataDirectory = dataDirectory
        self.profiles = profiles
    }
    
    func launch(profile: BrowserProfile, url: URL) { // TODO: add return
        fatalError("launch() must be overridden by subclass")
    }

    func getProfile(with name: String) -> BrowserProfile? {
        return profiles.first(where: { $0.id == name })
    }
    
    func retrieveProfiles() -> Result<[BrowserProfile], BrowserError> {
        fatalError("retrieveProfiles() must be overridden by subclass")
    }
}

// Defines what browsers are supported by the application.
struct BrowserConfig: Identifiable, Hashable {
    var id: String // MacOS bundle identifier
    var name: String // displayed
    var dataDirectory: String
    var type: BrowserType
    
    enum BrowserType {
        case chromium, firefox, webkit
    }
    
    func makeBrowserInstance() -> BaseBrowser {
        switch type {
        case .chromium:
            return ChromiumBrowser(id: id, name: name, dataDirectory: dataDirectory, profiles: [])
        default:
            fatalError("Unsupported browser")
        }
    }
}

enum BrowserError: Error {
    case couldNotGetBookmark
    case failedToStartScope
    case noFileContents
    case failedToDecodeJson(Error)
}

class ChromiumBrowser: BaseBrowser {
    
    override func launch(profile: BrowserProfile, url: URL) {
        guard let chromeURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: id
        ) else { return }
        
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true  // forces a launch that reads args - shouldn't actually spawn a new instance
        config.arguments = ["--profile-directory=\(profile.id)", url.absoluteString]
        config.activates = true
        NSWorkspace.shared.openApplication(at: chromeURL, configuration: config) { _, error in
            if let error {
                // TODO: improve error handling
                print("LAUNCH ERROR:", error)
            }
        }
    }
    
//    override func launch(profile: BrowserProfile, url: URL) {
//        guard let appURL = NSWorkspace.shared.urlForApplication(
//            withBundleIdentifier: id
//        ) else { return }
//
//        let execURL = appURL
//            .appendingPathComponent("Contents/MacOS/Brave Browser")
//
//        let process = Process()
//        process.executableURL = execURL
//        process.arguments = [
//            "--profile-directory=\(profile.id)",
//            url.absoluteString
//        ]
//        try? process.run()
//    }
    
    override func retrieveProfiles() -> Result<[BrowserProfile], BrowserError> {
//        Bookmark version not required without sandbox enabled
//        do {
//            guard let bookmark = UserDefaults.standard.data(forKey: "chromeDir") else {
//                return .failure(.couldNotGetBookmark)
//            }
//            
//            var stale = false
//            let url = try URL(
//                resolvingBookmarkData: bookmark,
//                options: .withSecurityScope,
//                relativeTo: nil,
//                bookmarkDataIsStale: &stale
//            )
//            
//            guard url.startAccessingSecurityScopedResource() else {
//                return .failure(.failedToStartScope)
//            }
//            defer { url.stopAccessingSecurityScopedResource() }
//            
//            let fm = FileManager.default
//            let fileurl = url.appendingPathComponent("Local State", conformingTo: .fileURL)
//            let path = fileurl.path
//            if let contents = fm.contents(atPath: path) {
//                let localState: ChromiumLocalState = try JSONDecoder().decode(ChromiumLocalState.self, from: contents)
//                let profiles = localState.convertToGenericProfiles(browser: self)
//                let sortedProfiles = profiles.sorted(using: KeyPathComparator(\.name))
//                self.profiles = sortedProfiles
//                return .success(profiles)
//            } else {
//                return .failure(.noFileContents)
//            }
//        } catch {
//            return .failure(.failedToDecodeJson(error))
//        }
        do {
            let expandedDataDirectory = (self.dataDirectory as NSString).expandingTildeInPath
            let fileURL = URL(filePath: expandedDataDirectory, directoryHint: .isDirectory)
                .appending(path: "Local State", directoryHint: .notDirectory)

            guard let contents = FileManager.default.contents(atPath: fileURL.path) else {
                return .failure(.noFileContents)
            }

            let localState = try JSONDecoder().decode(ChromiumLocalState.self, from: contents)
            let profiles = localState.convertToGenericProfiles(browser: self)
            self.profiles = profiles.sorted(using: KeyPathComparator(\.name))
            return .success(profiles)
        } catch {
            return .failure(.failedToDecodeJson(error))
        }
    }
}
