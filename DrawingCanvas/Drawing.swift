//
//  Drawing.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/11/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import CoreGraphics
import SwiftUI

struct Drawing: Identifiable {
    var id: UUID = UUID()
    
    var points: [CGPoint] = [CGPoint]()
    var lineWidth: CGFloat = 0
    var cornerRadius: CGFloat = 5
    var color: Color = .black
    var shapeType: ShapeType = .line
    
    enum ShapeType {
        case line
        case circle
        case rect
        case roundedRect
    }
}

