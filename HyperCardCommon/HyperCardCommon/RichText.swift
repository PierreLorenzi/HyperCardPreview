//
//  RichText.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


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
