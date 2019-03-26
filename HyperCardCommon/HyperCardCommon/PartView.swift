//
//  PartView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Drawing {
    
    /// Draws a rectangle with black borders
    func drawBorderedRectangle(_ rectangle: Rectangle, composition: ImageComposition = Drawing.MaskComposition, borderComposition: ImageComposition = Drawing.DirectComposition) {
        
        /* Draw the background */
        self.drawRectangle(rectangle, composition: composition)
        
        /* Draw the borders */
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: 1), composition: borderComposition)
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top + 1, width: 1, height: rectangle.height - 2), composition: borderComposition)
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.bottom-1, width: rectangle.width, height: 1), composition: borderComposition)
        self.drawRectangle(Rectangle(x: rectangle.right-1, y: rectangle.top + 1, width: 1, height: rectangle.height - 2), composition: borderComposition)
        
    }
    
    /// Draws a rectangle with black borders and a shadow
    func drawShadowedRectangle(_ rectangle: Rectangle, thickness: Int, shift: Int, composition: ImageComposition = Drawing.MaskComposition) {
        
        /* Draw the rectangle */
        self.drawBorderedRectangle(Rectangle(x: rectangle.x, y: rectangle.y, width: rectangle.width-thickness, height: rectangle.height-thickness), composition: composition)
        
        /* Draw the shadow */
        self.drawRectangle(Rectangle(top: rectangle.bottom-thickness, left: rectangle.left + shift, bottom: rectangle.bottom, right: rectangle.right))
        self.drawRectangle(Rectangle(top: rectangle.top + shift, left: rectangle.right - thickness, bottom: rectangle.bottom-thickness, right: rectangle.right))
        
    }
    
}


