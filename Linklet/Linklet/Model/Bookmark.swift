//
//  Bookmark.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import Foundation
import SwiftData

enum PatternType: Codable {
    case literal
    case regex
    case any
}

struct StringPattern: Codable {
    var type: PatternType
    var pattern: String
    
    static func literal(_ pattern: String) -> StringPattern {
        return StringPattern(type: .literal, pattern: pattern)
    }
    
    static func regex(_ pattern: String) -> StringPattern {
        return StringPattern(type: .regex, pattern: pattern)
    }
    
    static func any(_ pattern: String) -> StringPattern {
        return StringPattern(type: .any, pattern: pattern)
    }
}

extension StringPattern {
    var display: String {
        return pattern
    }
}

extension Optional where Wrapped == StringPattern {
    var display: String {
        if let definedSelf = self {
            return definedSelf.display // redirect to non-nillable property
        } else {
            return ""
        }
    }
}

extension Optional where Wrapped == StringPattern {
    var isNullOrEmpty: Bool {
        guard let definedSelf = self else {
            return true
        }
        
        return definedSelf.pattern.isEmpty
    }
}

struct UrlAuthorityPattern: Codable {
    // Authority Syntax - authority = [userinfo "@"] host [":" port] (ref:https://en.wikipedia.org/wiki/URL#Syntax)
    
    var userinfo: StringPattern = .any("")
    var host: StringPattern
    var port: StringPattern = .any("") // StringPattern permits leading 0s and regex
    
    init(userinfo: StringPattern? = nil, host: StringPattern, port: StringPattern? = nil) {
        self.userinfo = userinfo ?? .any("")
        self.host = host
        self.port = port ?? .any("")
    }
    
    static func create(from url: URL) -> UrlAuthorityPattern? {
        guard let stringHost = url.host() else {
            return nil
        }
        
        let userinfo: StringPattern? = nil // TODO: implement
        let host: StringPattern = .literal(stringHost)
        let port: StringPattern? = url.port.map { .literal(String($0)) }
        
        return UrlAuthorityPattern(userinfo: userinfo, host: host, port: port)
    }

    var qualified: String {
        let userInfo: String = self.userinfo.type == .any ? "" : self.userinfo.display + "@"
        let host: String = self.host.display
        let port: String = self.userinfo.type == .any ? "" : ":" + self.port.display
        return "//" + userInfo + host + port
    }
}

struct UrlPattern: Codable {
    // URI Syntax - URI = scheme ":" ["//" authority] path ["?" query] ["#" fragment] (ref: https://en.wikipedia.org/wiki/URL#Syntax)
    
    var scheme: StringPattern // http(s), (s)ftp, obsidian, etc.
    var authority: UrlAuthorityPattern
    var path: StringPattern
    var query: StringPattern = .any("")
    var fragment: StringPattern = .any("")
    
    init(scheme: StringPattern, authority: UrlAuthorityPattern, path: StringPattern, query: StringPattern?, fragment: StringPattern?) {
        self.scheme = scheme
        self.authority = authority
        self.path = path
        self.query = query ?? .any("")
        self.fragment = fragment ?? .any("")
    }
    
    static func create(from url: URL) -> UrlPattern? {
        guard let authority = UrlAuthorityPattern.create(from: url), let schemeString = url.scheme else {
            return nil
        }
        
        let scheme: StringPattern = .literal(schemeString)
        let path: StringPattern = .literal(url.path())
        let query: StringPattern? = url.query().map { .literal($0) }
        let fragment: StringPattern? = url.fragment().map { .literal($0) }
        
        let urlPattern: UrlPattern = .init(scheme: scheme, authority: authority, path: path, query: query, fragment: fragment)
        return urlPattern
        
        // TODO: reimplement
//        if self.qualified != url.absoluteString {
//            return nil
//        }
    }
    
    var qualified: String {
        let scheme = self.scheme.display
        let authority = self.authority.qualified
        let path = self.path.display
        let pathTrailingSlash: String = path.hasSuffix("/") ? "" : "/"
        let query = self.query.type == .any ? "" : "?" + self.query.display
        let fragment = self.fragment.type == .any ? "" : "#" + self.fragment.display
        let qaulified = scheme + ":" + authority + path + pathTrailingSlash + query + fragment
        print("QUAL: \(qaulified)")
        return qaulified
    }
}

@Model
class Bookmark: Identifiable, Hashable {
    var id: UUID
    var createdAt: Date
    var title: String
    var originalUrl: String
    
    var urlPattern: UrlPattern
    
    var matchingStrategy: DomainCard
    var browser: String // bundle identifer
    var browserProfile: String //
    
    var tags: [String]
    var favicon: String // SF Symbol name as a stand-in for a real favicon - TODO: replcae with data
    
    init(id: UUID = UUID(), createdAt: Date = Date(), title: String, originalUrl: String, urlPattern: UrlPattern, matchingStrategy: DomainCard = .exact, browser: String, browserProfile: String, tags: [String], favicon: String) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.originalUrl = originalUrl
        self.urlPattern = urlPattern
        self.matchingStrategy = matchingStrategy
        self.browser = browser
        self.browserProfile = browserProfile
        self.tags = tags
        self.favicon = favicon
    }
}

extension Bookmark {
    static let mock: [Bookmark] = [

    ]
}
