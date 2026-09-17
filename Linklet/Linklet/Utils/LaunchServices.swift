//
//  LaunchServices.swift
//  Linklet
//
//  Created by Chef on 8/26/26.
//

import AppKit

func isAppInstalled(bundleID: String) -> Bool {
    NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) != nil
}
