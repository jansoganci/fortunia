//
//  Elevation+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Elevation System
struct Elevation {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static let level1 = Elevation(
        color: Color.black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let level2 = Elevation(
        color: Color.black.opacity(0.1),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let level3 = Elevation(
        color: Color.black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let level4 = Elevation(
        color: Color.black.opacity(0.2),
        radius: 16,
        x: 0,
        y: 8
    )
    
    static let level5 = Elevation(
        color: Color.black.opacity(0.25),
        radius: 24,
        x: 0,
        y: 12
    )
}

// MARK: - View Extension
extension View {
    func elevation(_ elevation: Elevation) -> some View {
        self.shadow(
            color: elevation.color,
            radius: elevation.radius,
            x: elevation.x,
            y: elevation.y
        )
    }
}
