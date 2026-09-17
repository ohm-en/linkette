//
//  LocalState.swift
//  Linklet
//
//  Created by Chef on 8/23/26.
//

//   let localState = try? JSONDecoder().decode(LocalState.self, from: jsonData)

import Foundation

// MARK: - LocalState
struct ChromiumLocalState: Codable {
    let profile: Profile

    enum CodingKeys: String, CodingKey {
        case profile = "profile"
    }
        
    func convertToGenericProfiles(browser: ChromiumBrowser) -> [BrowserProfile] {
        let profiles: [BrowserProfile] = self.profile.infoCache.map { key, profileInfo in
            return .init(id: key, name: profileInfo.name, browser: browser)
        }
        
        return profiles
    }
}

// MARK: - Profile
struct Profile: Codable {
    let infoCache: [String: InfoCache]
    let lastActiveProfiles: [String]
//    let lastUsed: String
//    let metrics: Metrics
//    let pickerShown: Bool
//    let profileCountsReported: String
//    let profilesCreated: Int
    let profilesOrder: [String]

    enum CodingKeys: String, CodingKey {
        case infoCache = "info_cache"
        case lastActiveProfiles = "last_active_profiles"
//        case lastUsed = "last_used"
//        case metrics = "metrics"
//        case pickerShown = "picker_shown"
//        case profileCountsReported = "profile_counts_reported"
//        case profilesCreated = "profiles_created"
        case profilesOrder = "profiles_order"
    }
}

// MARK: - InfoCache
struct InfoCache: Codable {
//    let activeTime: Double
//    let avatarIcon: String
//    let backgroundApps: Bool
//    let defaultAvatarFillColor: Int
//    let defaultAvatarStrokeColor: Int
//    let enterpriseLabel: String
//    let forceSigninProfileLocked: Bool
//    let gaiaID: String
//    let isConsentedPrimaryAccount: Bool
//    let isEphemeral: Bool
//    let isUsingDefaultAvatar: Bool
//    let isUsingDefaultName: Bool
//    let managedUserID: String
//    let metricsBucketIndex: Int
    let name: String
//    let profileColorSeed: Int
//    let profileHighlightColor: Int
//    let signinWithCredentialProvider: Bool
    let userName: String
//    let useGaiaPicture: Bool?

    enum CodingKeys: String, CodingKey {
//        case activeTime = "active_time"
//        case avatarIcon = "avatar_icon"
//        case backgroundApps = "background_apps"
//        case defaultAvatarFillColor = "default_avatar_fill_color"
//        case defaultAvatarStrokeColor = "default_avatar_stroke_color"
//        case enterpriseLabel = "enterprise_label"
//        case forceSigninProfileLocked = "force_signin_profile_locked"
//        case gaiaID = "gaia_id"
//        case isConsentedPrimaryAccount = "is_consented_primary_account"
//        case isEphemeral = "is_ephemeral"
//        case isUsingDefaultAvatar = "is_using_default_avatar"
//        case isUsingDefaultName = "is_using_default_name"
//        case managedUserID = "managed_user_id"
//        case metricsBucketIndex = "metrics_bucket_index"
        case name = "name"
//        case profileColorSeed = "profile_color_seed"
//        case profileHighlightColor = "profile_highlight_color"
//        case signinWithCredentialProvider = "signin.with_credential_provider"
        case userName = "user_name"
//        case useGaiaPicture = "use_gaia_picture"
    }
}

// MARK: - Metrics
struct Metrics: Codable {
    let nextBucketIndex: Int

    enum CodingKeys: String, CodingKey {
        case nextBucketIndex = "next_bucket_index"
    }
}
