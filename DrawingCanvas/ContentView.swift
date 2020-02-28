//
//  ContentView.swift
//  DrawingCanvas
//
//  Created by Ethan Humphrey on 11/11/19.
//  Copyright © 2019 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var drawings = [Drawing()]
    @State var redoDrawings = [Drawing]()
    @State var colorSelection: ColorSelection = ColorSelection()
    @State var lineWidth: CGFloat = 3.0
    @State var cornerRadius: CGFloat = 20
    @State var gridSpacing: CGFloat = 10.0
    @State var shapeSelection: ShapeSelection = ShapeSelection()
    
    @State var showColorPicker = false
    @State var showShapePicker = false
    @State var showShareSheet = false
    @State var isSnapping = false
    @State var showGrid = false
    
    @State var drawingRect: CGRect = .zero
    
    @State var drawingImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                DrawingPad(drawings: self.$drawings, redoDrawings: self.$redoDrawings, colorSelection: self.$colorSelection, lineWidth: self.$lineWidth, cornerRadius: self.$cornerRadius, shapeSelection: self.$shapeSelection, isSnapping: self.$isSnapping, showGrid: self.$showGrid, gridSpacing: self.$gridSpacing)
                    .background(RectGetter(rect: self.$drawingRect))
                HStack {
                    Button(action: {
                        self.showShapePicker = true
                    }) {
                        Spacer()
                        Text("Shape: \(self.shapeSelection.shapeName)")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .actionSheet(isPresented: self.$showShapePicker, content: {
                        ActionSheet(title: Text("Pick a Shape"), message: nil, buttons: self.getShapeButtons())
                    })
                    Button(action: {
                        self.showColorPicker = true
                    }) {
                        Spacer()
                        Text("Color: \(self.colorSelection.colorName)")
                        Spacer()
                    }
                    .actionSheet(isPresented: self.$showColorPicker, content: {
                        ActionSheet(title: Text("Pick a Color"), message: nil, buttons: self.getColorButtons())
                    })
                }
                .padding(8)
                HStack {
                    Button(action: {
                        self.redoDrawings.append(self.drawings[self.drawings.count - 2])
                        self.drawings.remove(at: self.drawings.count - 2)
                        if self.drawings.count == 0 {
                            self.drawings.append(Drawing())
                        }
                    }) {
                        Spacer()
                        Text("Undo")
                        Spacer()
                    }
                    .disabled(self.drawings.count <= 1 && self.drawings.first?.points.count == 0)
                    Button(action: {
                        self.drawings[self.drawings.count - 1] = self.redoDrawings[self.redoDrawings.count - 1]
                        self.drawings.append(Drawing())
                        self.redoDrawings.remove(at: self.redoDrawings.count - 1)
                    }) {
                        Spacer()
                        Text("Redo")
                        Spacer()
                    }
                    .disabled(self.redoDrawings.count == 0)
                }
                .padding(8)
                withAnimation {
                    Toggle(isOn: self.$showGrid) {
                        Text("Show Grid")
                    }
                }
                .padding(.horizontal)
                if self.showGrid {
                    Toggle(isOn: self.$isSnapping) {
                        Text("Enable Grid Snapping")
                    }
                    .padding(.horizontal)
                    .transition(.slideDown)
                    HStack {
                        Text("Grid Spacing: \(Int(self.gridSpacing))")
                        Spacer()
                        Slider(value: self.$gridSpacing, in: 5 ... 100)
                            .frame(width: geometry.size.width*0.5, height: nil, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .transition(.slideDown)
                }
                if self.shapeSelection.shape == .line {
                    HStack {
                        Text("Line Width: \(Int(self.lineWidth))")
                        Spacer()
                        Slider(value: self.$lineWidth, in: 1 ... 100)
                        .frame(width: geometry.size.width*0.5, height: nil, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .transition(.slideDown)
                }
                if self.shapeSelection.shape == .roundedRect {
                    HStack {
                        Text("Corner Radius: \(Int(self.cornerRadius))")
                        Spacer()
                        Slider(value: self.$cornerRadius, in: 5 ... 100)
                        .frame(width: geometry.size.width*0.5, height: nil, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .transition(.slideDown)
                }
                Button(action: {
                    self.showGrid = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.drawingImage = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.drawingRect)
                        self.showShareSheet = true
                    })
                }) {
                    Text("Share Drawing")
                        .padding(12)
                        .background(Color(.systemGreen))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            .sheet(isPresented: self.$showShareSheet) {
                ShareSheet(activityItems: [self.drawingImage])
            }
        }
        .accentColor(Color(.systemGreen))
    }
    
    func getColorButtons() -> [Alert.Button] {
        var alertButtons = [Alert.Button]()
        for color in ColorSelection.possibleColors {
            alertButtons.append(.default(Text(color.colorName), action: {
                withAnimation {
                    self.colorSelection = color
                }
            }))
        }
        alertButtons.append(.cancel())
        return alertButtons
    }
    
    func getShapeButtons() -> [Alert.Button] {
        var alertButtons = [Alert.Button]()
        for shape in ShapeSelection.possibleShapes {
            alertButtons.append(.default(Text(shape.shapeName), action: {
                withAnimation {
                    self.shapeSelection = shape
                }
            }))
        }
        alertButtons.append(.cancel())
        return alertButtons
    }
}

struct RectGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}


extension AnyTransition {
    static var slideDown: AnyTransition {
        let insertion = AnyTransition.offset(x: 0, y: 1000)
            .combined(with: .opacity)
        let removal = AnyTransition.offset(x: 0, y: 1000)
        .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
