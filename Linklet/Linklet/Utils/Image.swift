//
//  Image.swift
//  Linklet
//
//  Created by Chef on 10/9/26.
//

import AppKit

extension NSImage {
    func sized(_ side: CGFloat) -> NSImage {
        let copy = self.copy() as! NSImage
        copy.size = NSSize(width: side, height: side)
        return copy
    }
}
