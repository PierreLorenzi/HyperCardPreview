//
//  PartView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// Ints representing an gray image
public let Grays = [ UInt32(0xAAAA_AAAA), UInt32(0x5555_5555) ]

/// The composition applied to a part image to make it look disabled
public let DisabledComposition: ImageComposition = { (a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
    
    let gray = Grays[y % 2]
    let inverseGray = Grays[1 - y % 2]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}

/// The composition applied to a hilited part image to make it look disabled
public let BlackToGrayComposition: ImageComposition = { (a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
    
    let inverseGray = Grays[1 - y % 2]
    a &= ~(b & inverseGray)
    
}

/// Shift between buttons and their shadows, in pixels
public let ButtonShadowShift = 2

/// Thickness of the shadows of the buttons, in pixels
public let ButtonShadowThickness = 1


public extension Drawing {
    
    /// Draws a rectangle with black borders
    public func drawBorderedRectangle(_ rectangle: Rectangle, composition: ImageComposition = Drawing.MaskComposition) {
        
        /* Draw the background */
        self.drawRectangle(rectangle, composition: composition)
        
        /* Draw the borders */
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: 1))
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.top, width: 1, height: rectangle.height))
        self.drawRectangle(Rectangle(x: rectangle.left, y: rectangle.bottom-1, width: rectangle.width, height: 1))
        self.drawRectangle(Rectangle(x: rectangle.right-1, y: rectangle.top, width: 1, height: rectangle.height))
        
    }
    
    /// Draws a rectangle with black borders and a shadow
    public func drawShadowedRectangle(_ rectangle: Rectangle, thickness: Int, shift: Int, composition: ImageComposition = Drawing.MaskComposition) {
        
        /* Draw the rectangle */
        self.drawBorderedRectangle(Rectangle(x: rectangle.x, y: rectangle.y, width: rectangle.width-thickness, height: rectangle.height-thickness), composition: composition)
        
        /* Draw the shadow */
        self.drawRectangle(Rectangle(top: rectangle.bottom-thickness, left: rectangle.left + shift, bottom: rectangle.bottom, right: rectangle.right))
        self.drawRectangle(Rectangle(top: rectangle.top + shift, left: rectangle.right - thickness, bottom: rectangle.bottom-thickness, right: rectangle.right))
        
    }
    
}


/// A string ready to be drawn, where the attributes are low-level bitmap fonts and not
/// user-friendly styles
public struct RichText {
    
    /// The string
    public var string: HString          = ""
    
    /// The drawing attributes
    public var attributes: [Attribute]  = []
    
    /// Applies a font to a portion of the string
    public struct Attribute {
        
        /// The offset where the attribute starts being applied in the string
        public var index: Int
        
        /// The font to draw the string with
        public var font: BitmapFont
        
        public init(index: Int, font: BitmapFont) {
            self.index = index
            self.font = font
        }
    }
}

