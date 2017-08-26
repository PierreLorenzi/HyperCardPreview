//
//  WhiteView.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view displaying white, used for the window background
public class WhiteView: View {
    
    /// The position of the view
    public override var rectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 10000, right: 10000)
    }
    
    /// If the view accepts to draw only sub-rectangles of itself.
    public override var canDrawSubrectangle: Bool {
        return true
    }
    
    /// Draws the object on the drawing
    public override func draw(in drawing: Drawing) {
        let wholeRectangle = Rectangle(top: 0, left: 0, bottom: drawing.height, right: drawing.width)
        drawing.drawRectangle(wholeRectangle, composition: Drawing.MaskComposition)
    }
    
    /// Draws a part of the object on the drawing (called if canDrawSubrectangle returns true)
    public override func draw(in drawing: Drawing, rectangle: Rectangle) {
        drawing.drawRectangle(rectangle, composition: Drawing.MaskComposition)
    }
    
}
