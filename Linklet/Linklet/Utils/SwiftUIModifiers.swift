//
//  SwiftUIModifiers.swift
//  Linklet
//
//  Created by Chef on 9/22/26.
//

import SwiftUI

extension View {
    func onChange<V>(
        of value: V,
        debounce duration: Duration,
        perform action: @escaping (V, V) -> Void
    ) -> some View where V : Equatable {
        modifier(DebouncedChange(value: value, duration: duration, action: action))
    }
}

// TODO: test for accuracy
private struct DebouncedChange<V>: ViewModifier where V : Equatable {
    let value: V
    let duration: Duration
    let action: (V, V) -> Void
    @State private var debounceTask: Task<Void, Never>? = nil

    func body(content: Content) -> some View {
        content.onChange(of: value) { old, new in
            if let existingTask = debounceTask { existingTask.cancel() }
            
            debounceTask = Task {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: duration)
                guard !Task.isCancelled else { return }
                await MainActor.run { action(old, new) }
            }
        }
    }
}
