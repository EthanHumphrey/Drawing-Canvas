//
//  ShapeSelection.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/15/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import Foundation

struct ShapeSelection: Identifiable, Hashable {
    var id: Drawing.ShapeType {
        return self.shape
    }
    var shape: Drawing.ShapeType = .line
    var shapeName: String = "Line"
    
    static let possibleShapes = [
        ShapeSelection(shape: .line, shapeName: "Line"),
        ShapeSelection(shape: .circle, shapeName: "Circle"),
        ShapeSelection(shape: .rect, shapeName: "Rectangle"),
        ShapeSelection(shape: .roundedRect, shapeName: "Rounded Rectangle")
    ]
}
