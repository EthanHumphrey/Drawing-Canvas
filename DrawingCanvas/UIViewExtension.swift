//
//  UIViewExtension.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/15/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
