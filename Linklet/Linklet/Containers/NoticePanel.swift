//
//  NoticePanel.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

import SwiftUI

struct NoticeContainer<Content: View>: View {
    let onClose: () -> Void
    let content: Content

    private let radius: CGFloat = 10
    private let overhang: CGFloat = 8 // how far the X sticks out
    private let closeButtonSize: CGFloat = 30
    private let closeButtonXFont: CGFloat = 16

    var body: some View {
        content
            .background(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color(nsColor: .separatorColor))
            )
            .overlay(alignment: .topLeading) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: closeButtonXFont, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: closeButtonSize, height: closeButtonSize)
                        .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
                        .overlay(Circle().strokeBorder(Color(nsColor: .separatorColor)))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .offset(x: -overhang, y: -overhang)
            }
            // Transparent margin so the window is big enough to contain the X
            .padding(overhang)
    }
}

final class NoticePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    init<Content: View>(@ViewBuilder view: () -> Content) {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true

        // Transparent window; the SwiftUI NoticeContainer draws the visible shape
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        let root = NoticeContainer( // allows custom close button
            onClose: { [weak self] in self?.orderOut(nil) },
            content: view()
        )
        
        let hosting = NSHostingView(rootView: root)
        hosting.sizingOptions = [.preferredContentSize]
        contentView = hosting

        center()
    }
    
    override func makeKeyAndOrderFront(_ sender: Any?) {
        center()
        super.makeKeyAndOrderFront(sender)
        invalidateShadow()
    }

    // Allows ESC to close window
    override func cancelOperation(_ sender: Any?) { orderOut(nil) }
    // TODO: fix ⌘W not closing window
}
