//
//  PanelManager.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import SwiftUI
import System
import KeyboardShortcuts
internal import Combine

final class NoticeManager {
    private var vc: RedirectManager
    private var browserService: BrowserService
    private var panel: NoticePanel?
    
    init(vc: RedirectManager, browserService: BrowserService) {
        self.vc = vc
        self.browserService = browserService
    }
    
    func observeCurrentURL() {
        withObservationTracking {
            _ = vc.currentRedirectWizard
        } onChange: {
            Task { @MainActor in
                if self.vc.currentRedirectWizard == nil {
                    self.hidePanel()
                } else {
                    self.showPanel()
                }
                self.observeCurrentURL() // re-arm
            }
        }
    }

    public func setup() {
        browserService.refresh()
        observeCurrentURL()
    }

    private func makePanel() -> NoticePanel {
        NoticePanel {
            LinkRedirectWindow(vm: vc)
                .fixedSize()
                .padding(25)
                .environment(browserService)
                .task{
                    self.browserService.refresh()
                }
        }
    }

    public func showPanel() {
        let panel = panel ?? makePanel()
        self.panel = panel
        panel.makeKeyAndOrderFront(nil)
    }

    public func hidePanel() {
        if let panel {
            panel.orderOut(nil)
        }
        // don't bother hiding a non-existant panel
    }

    public func togglePanel() {
        print("Toggling Panek")
        if let panel, panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
}
