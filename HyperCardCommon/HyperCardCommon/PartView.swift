//
//  PartView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public let Grays = [ UInt32(0xAAAA_AAAA), UInt32(0x5555_5555) ]
public let DisabledComposition: ImageComposition = { (a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
    
    let gray = Grays[y % 2]
    let inverseGray = Grays[1 - y % 2]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}
public let BlackToGrayComposition: ImageComposition = { (a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
    
    let inverseGray = Grays[1 - y % 2]
    a &= ~(b & inverseGray)
    
}

public let ButtonShadowShift = 2
public let ButtonShadowThickness = 1


public extension Drawing {
    
    public func drawBorderedRectangle(_ rectangle: Rectangle, composition: ImageComposition = Drawing.MaskComposition) {
        
        /* Draw the background */
        self.drawRectangle(rectangle, composition: composition)
        
        /* Draw the borders */
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: 1))
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top, width: 1, height: rectangle.height))
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.bottom-1, width: rectangle.width, height: 1))
        self.drawRectangle(Rectangle(x: rectangle.right-1, y: rectangle.top, width: 1, height: rectangle.height))
        
    }
    
    public func drawShadowedRectangle(_ rectangle: Rectangle, thickness: Int, shift: Int, composition: ImageComposition = Drawing.MaskComposition) {
        
        /* Draw the rectangle */
        self.drawBorderedRectangle(Rectangle(x: rectangle.x, y: rectangle.y, width: rectangle.width-thickness, height: rectangle.height-thickness), composition: composition)
        
        /* Draw the shadow */
        self.drawRectangle(Rectangle(top: rectangle.bottom-thickness, left: rectangle.left + shift, bottom: rectangle.bottom, right: rectangle.right))
        self.drawRectangle(Rectangle(top: rectangle.top + shift, left: rectangle.right - thickness, bottom: rectangle.bottom-thickness, right: rectangle.right))
        
    }
    
}


public struct RichText {
    public var string: HString          = ""
    public var attributes: [Attribute]  = []
    
    public struct Attribute {
        public var index: Int
        public var font: BitmapFont
        
        public init(index: Int, font: BitmapFont) {
            self.index = index
            self.font = font
        }
    }
}

