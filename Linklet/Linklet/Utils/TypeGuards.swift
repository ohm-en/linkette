//
//  TypeGuards.swift
//  Linklet
//
//  Created by Chef on 8/4/26.
//

extension Optional where Wrapped == String {
    var isNullOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
