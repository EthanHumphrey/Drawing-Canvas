//
//  DrawingPad.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/11/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct DrawingPad: View {
    @Binding var drawings: [Drawing]
    @Binding var redoDrawings: [Drawing]
    @Binding var colorSelection: ColorSelection
    @Binding var lineWidth: CGFloat
    @Binding var cornerRadius: CGFloat
    @Binding var shapeSelection: ShapeSelection
    @Binding var isSnapping: Bool
    @Binding var showGrid: Bool
    @Binding var gridSpacing: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(self.drawings, id: \.id) { drawing in
                    Path { path in
                        self.add(drawing: drawing, toPath: &path)
                    }
                    .fill(drawing.color)
                }
                if self.showGrid {
                    Path { path in
                        for y in 0 ... Int(geometry.size.height/self.gridSpacing) {
                            path.move(to: CGPoint(x: 0, y: CGFloat(y)*self.gridSpacing))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: CGFloat(y)*self.gridSpacing))
                        }
                        for x in 0 ... Int(geometry.size.width/self.gridSpacing) {
                            path.move(to: CGPoint(x: CGFloat(x)*self.gridSpacing, y: 0))
                            path.addLine(to: CGPoint(x: CGFloat(x)*self.gridSpacing, y: geometry.size
                                .height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: 1)
                    .transition(.opacity)
                }
            }
            .background(Color(white: 1.0))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        if self.drawings.last!.lineWidth == 0 {
                            self.drawings[self.drawings.count - 1].lineWidth = self.lineWidth
                            self.drawings[self.drawings.count - 1].color = self.colorSelection.color
                            self.drawings[self.drawings.count - 1].shapeType = self.shapeSelection.shape
                            self.drawings[self.drawings.count - 1].cornerRadius = self.cornerRadius
                        }
                        let currentPoint = value.location
                        if currentPoint.y >= 0 && currentPoint.y < geometry.size.height - self.lineWidth {
                            let thisDrawing = self.drawings[self.drawings.count - 1]
                            if thisDrawing.points.count == 0 {
                                if !self.isSnapping {
                                    self.drawings[self.drawings.count - 1].points.append(currentPoint)
                                }
                                else {
                                    self.drawings[self.drawings.count - 1].points.append(self.getSnappedPoint(from: currentPoint))
                                }
                            }
                            else {
                                if !self.isSnapping {
                                    switch thisDrawing.shapeType {
                                    case .line:
//                                        if !self.isSnapping {
                                            self.drawings[self.drawings.count - 1].points.append(currentPoint)
//                                        }
//                                        else {
//                                            let points = thisDrawing.points
//                                            let firstPoint = points.first!
//                                            let angle = self.getAngleBetween(firstPoint, and: currentPoint)
//                                            let correctedAngle = self.getClosestSnappingAngle(to: angle)
//                                            let currentLength = self.getDistanceBetween(firstPoint, and: currentPoint)
//                                            let correctedPoint = CGPoint(x: firstPoint.x + currentLength*cos(correctedAngle), y: firstPoint.y + currentLength*sin(correctedAngle))
//                                            if points.count == 1 {
//                                                self.drawings[self.drawings.count - 1].points.append(correctedPoint)
//                                            }
//                                            else {
//                                                self.drawings[self.drawings.count - 1].points[1] = correctedPoint
//                                            }
//                                        }
                                    case .rect, .circle, .roundedRect:
                                        if thisDrawing.points.count == 1 {
                                            self.drawings[self.drawings.count - 1].points.append(currentPoint)
                                        }
                                        else {
                                            self.drawings[self.drawings.count - 1].points[1] = currentPoint
                                        }
                                    }
                                }
                                else {
                                    let snappedPoint = self.getSnappedPoint(from: currentPoint)
                                    if thisDrawing.points.count == 1 {
                                        self.drawings[self.drawings.count - 1].points.append(snappedPoint)
                                    }
                                    else {
                                        self.drawings[self.drawings.count - 1].points[1] = snappedPoint
                                    }
                                }
                            }
                        }
                    })
                    .onEnded({ (value) in
                        self.drawings.append(Drawing())
                        self.redoDrawings = []
                    })
            )
        }
        .frame(maxHeight: .infinity)
    }
    
    private func add(drawing: Drawing, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            switch drawing.shapeType {
            case .line:
                for i in 0..<points.count-1 {
                    let current = points[i]
                    let next = points[i+1]
                    path.addEllipse(in: CGRect(x: current.x-(drawing.lineWidth/2), y: current.y-(drawing.lineWidth/2), width: drawing.lineWidth, height: drawing.lineWidth))
                    let rectPath = Path(CGRect(x: 0, y: 0, width: getDistanceBetween(current, and: next), height: drawing.lineWidth))
                    let angle = getAngleBetween(current, and: next)
                    let newPath = rectPath.applying(CGAffineTransform(rotationAngle: angle))
                    let newNewPath = newPath.offsetBy(dx: current.x + (cos(angle - .pi/2)*drawing.lineWidth)/2, dy: current.y - (sin(angle + .pi/2)*drawing.lineWidth)/2)
                    path.addPath(newNewPath as! Path)
                    path.addEllipse(in: CGRect(x: next.x-(drawing.lineWidth/2), y: next.y-(drawing.lineWidth/2), width: drawing.lineWidth, height: drawing.lineWidth))
                }
            case .circle:
                let center = points.first!
                let next = points[1]
                path.move(to: center)
                let radius = getDistanceBetween(center, and: next)
                path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
            case .rect:
                let first = points.first!
                let next = points[1]
                path.move(to: first)
                path.addRect(CGRect(x: first.x, y: first.y, width: next.x - first.x, height: next.y - first.y))
            case .roundedRect:
                let first = points.first!
                let next = points[1]
                path.move(to: first)
                path.addRoundedRect(in: CGRect(x: first.x, y: first.y, width: next.x - first.x, height: next.y - first.y), cornerSize: CGSize(width: drawing.cornerRadius
                    , height: drawing.cornerRadius))
            }
            
        }
    }
    
    func getAngleBetween(_ firstPoint: CGPoint, and secondPoint: CGPoint) -> CGFloat {
        var angle: CGFloat = 0
        if firstPoint.x == secondPoint.x {
            if firstPoint.y < secondPoint.y {
                angle = .pi/2
            }
            else {
                angle = -.pi/2
            }
        }
        else {
            angle = atan((firstPoint.y - secondPoint.y)/(firstPoint.x - secondPoint.x))
        }
        if firstPoint.x > secondPoint.x{
            angle = angle + .pi
        }
        return angle
    }
    
    var supportedAngles: [CGFloat] {
        let baseAngles: [CGFloat] = [.pi/6, .pi/4, .pi/3, .pi/2]
        var allAngles: [CGFloat] = [0]
        for thisAngle in baseAngles {
            for n in -1 ..< Int(((2 * .pi)/thisAngle) - 1) {
                allAngles.append(thisAngle * CGFloat(n))
            }
        }
        return allAngles
    }
    
    func getClosestSnappingAngle(to originalAngle: CGFloat) -> CGFloat {
        let closest = supportedAngles.enumerated().min( by: { abs($0.1 - originalAngle) < abs($1.1 - originalAngle) } )!
        print("Current: \(originalAngle)")
        print("Closest: \(closest.element)")
        return closest.element
    }
    
    func getDistanceBetween(_ firstPoint: CGPoint, and secondPoint: CGPoint) -> CGFloat {
        return sqrt(pow((secondPoint.x - firstPoint.x), 2) + pow((secondPoint.y - firstPoint.y), 2))
    }
    
    func getSnappedPoint(from originalPoint: CGPoint) -> CGPoint {
        var xRemainder = originalPoint.x.truncatingRemainder(dividingBy: gridSpacing)
        if xRemainder > self.gridSpacing/2 {
            xRemainder -= self.gridSpacing
        }
        let newX = originalPoint.x - xRemainder
        
        var yRemainder = originalPoint.y.truncatingRemainder(dividingBy: gridSpacing)
        if yRemainder > self.gridSpacing/2 {
            yRemainder -= self.gridSpacing
        }
        let newY = originalPoint.y - yRemainder
        
        return CGPoint(x: newX, y: newY)
    }
    
}

struct DrawingPad_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
