//
//  WhiteView.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view displaying white, used for the window background
public class WhiteView: View, ClipableView {
    
    public override var rectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 10000, right: 10000)
    }
    
    public override func draw(in drawing: Drawing) {
        let wholeRectangle = Rectangle(top: 0, left: 0, bottom: drawing.height, right: drawing.width)
        drawing.drawRectangle(wholeRectangle, composition: Drawing.MaskComposition)
    }
    
    public func draw(in drawing: Drawing, rectangle: Rectangle) {
        drawing.drawRectangle(rectangle, composition: Drawing.MaskComposition)
    }
    
}
