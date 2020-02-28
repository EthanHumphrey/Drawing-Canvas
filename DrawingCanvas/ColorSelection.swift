//
//  ColorSelection.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/14/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct ColorSelection: Identifiable, Hashable {
    var id: Color {
        return self.color
    }
    var color: Color = .black
    var colorName: String = "Black"
    
    static let possibleColors = [
        ColorSelection(color: .black, colorName: "Black"),
        ColorSelection(color: .blue, colorName: "Blue"),
        ColorSelection(color: .gray, colorName: "Gray"),
        ColorSelection(color: .green, colorName: "Green"),
        ColorSelection(color: .orange, colorName: "Orange"),
        ColorSelection(color: .pink, colorName: "Pink"),
        ColorSelection(color: .purple, colorName: "Purple"),
        ColorSelection(color: .red, colorName: "Red"),
        ColorSelection(color: .white, colorName: "White"),
        ColorSelection(color: .yellow, colorName: "Yellow")
    ]
}
