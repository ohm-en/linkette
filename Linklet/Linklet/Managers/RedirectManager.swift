//
//  RedirectManager.swift
//  Linklet
//
//  Created by Chef on 8/20/26.
//

import SwiftUI
import SwiftData
internal import Combine

@Observable
class RedirectWizardManager: Hashable {
    static func == (lhs: RedirectWizardManager, rhs: RedirectWizardManager) -> Bool {
        // TODO: make this more robust; user may link the same url multiple times
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    var redirectManager: RedirectManager
    
    var url: URL
    var title: String = ""
    var favicon: CGImage? = nil
    
    var selectedBrowser: BaseBrowser
    var selectedProfile: BrowserProfile
    var matchchoice: DomainCard
    
    var isInvalidBookmark: Bool {
        let blacklistedMatchTypes: [DomainCard] = [.hostname, .wildcard]
        if blacklistedMatchTypes.contains(matchchoice) { return true }
        return false
    }
    
    init(redirectManager: RedirectManager, url: URL, selectedBrowser: BaseBrowser, selectedProfile: BrowserProfile, matchchoice: DomainCard = .exact) {
        self.redirectManager = redirectManager
        self.url = url
        self.selectedBrowser = selectedBrowser
        self.selectedProfile = selectedProfile
        self.matchchoice = matchchoice
    }
    
    func close() {
        redirectManager.removePendingWizard(wizard: self)
    }
    
    func open() {
        selectedBrowser.launch(profile: selectedProfile, url: url)
        self.close()
    }
    
    func save() {
        guard let pattern: UrlPattern = .create(from: url) else {
            print("FAILED TO PARSE URL")
            return // TODO: add warning
        }
        
        let bookmark: Bookmark = .init(
            title: self.title,
            originalUrl: url.absoluteString,
            urlPattern: pattern,
            matchingStrategy: matchchoice,
            browser: selectedBrowser.id,
            browserProfile: selectedProfile.id,
            tags: [],
            favicon: "" // TODO: store favicon for later use
        )
        
        self.redirectManager.save(new: bookmark)
    }
    
    func saveAndOpen() {
        selectedBrowser.launch(profile: selectedProfile, url: url)
        self.save()
        self.close()
    }
    
}

@Observable
class RedirectManager {
    let context = DataStack.mainContext
    let browserService: BrowserService
    
    var pendingRedirectWizards: [RedirectWizardManager] = []
    var currentRedirectWizard: RedirectWizardManager? { pendingRedirectWizards.first }
    
    init(browserService: BrowserService) {
        self.browserService = browserService
    }
    
    func save(new bookmark: Bookmark) {
        print("adding bookmark with \(bookmark.urlPattern.qualified)")
        context.insert(bookmark)
    }
    
    func findMatch(for target: URL) -> Bookmark? {
        do {
            guard let host = target.host() else {
                return nil // TODO: better handle path
            }
            
            let basicMatchDescriptor = FetchDescriptor<Bookmark>(
                predicate: #Predicate { $0.urlPattern.authority.host.pattern == host },
                sortBy: [.init(\.createdAt)] // TODO: ensure sorting is correct.
            )
            
            let basicMatchResults: [Bookmark] = try context.fetch(basicMatchDescriptor)
            
            print("matching \(target.absoluteString)")
            
            if let exactMatch = basicMatchResults.first(where: { $0.matchingStrategy == .exact && $0.urlPattern.qualified == target.absoluteString }) {
                return exactMatch
            }
            
            
            if let domainMatch = basicMatchResults.first(where: { $0.matchingStrategy == .domain }) {
                return domainMatch // fetch already ensures the host matched
            }
            
//                    let wildcardMatchDescriptor = FetchDescriptor<Bookmark>(
//                        predicate: #Predicate { $0.matchingStrategy == DomainCard.wildcard },
//                        sortBy: [.init(\.createdAt)] // TODO: ensure sorting is correct.
//                    )
            
            // TODO: split regex into segments so we can regexi n piece mail. Allows to query more narrow
            
            // TODO: implement regex match
            //             `url.absoluteString` is treated as the regex pattern.
            //        guard let regex = try? Regex<AnyRegexOutput>(url.absoluteString) else {
            //            return nil
            //        }
            //        let all = (try? context.fetch(FetchDescripto<Bookmark>())) ?? []
            //        return all.first { $0.rawUri.contains(regex) }
            
            return nil
        } catch {
            print("failed to fetch: \(error)") // TODO: improve error
            return nil
        }
    }
    
    
    @discardableResult
    func removePendingWizard(wizard: RedirectWizardManager) -> Bool {
        guard let wizardIndex = pendingRedirectWizards.firstIndex(where: { $0 == wizard }) else {
            return false
        }
        
        pendingRedirectWizards.remove(at: wizardIndex)
        
        return true
    }
    
    func intake(url: URL) {
        if let match = findMatch(for: url) {
            if let browserProfile = browserService.getBrowserProfile(for: match.browser, named: match.browserProfile) {
                browserProfile.launch(url: url)
            } else {
                print("FAILED TO FIND PROFILE \(match.browser) .. \(match.browserProfile)")
                // TODO: alert or something
            }
        } else {
            guard let defaultProfile = browserService.getDefaultProfile() else {
                notifyUserOfRedirectionFailure() // TOOD: complete error handling
                return
            }
            
            let wizardManager: RedirectWizardManager = .init(redirectManager: self, url: url, selectedBrowser: defaultProfile.browser, selectedProfile: defaultProfile)
            pendingRedirectWizards.append(wizardManager)
        }
    }
    
    func cancel() {
        pendingRedirectWizards.remove(at: 0)
    }
    
    // TODO: implement
    func notifyUserOfRedirectionFailure() {
        print("REDIRECT failure")
    }
}
