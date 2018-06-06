//
//  VectorFont.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A vector font in TrueType format
public struct VectorFont {
    
    /// The CoreGraphics font used to represent the font. A CGFont can be initialized
    /// directly on a font file data, and that's what the vector font resources are.
    public var cgfont: CGFont
}
