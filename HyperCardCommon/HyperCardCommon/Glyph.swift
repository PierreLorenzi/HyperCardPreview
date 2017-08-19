//
//  BitmapFontCharacter.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A glyph in a bitmap font.
/// <p>
/// It is a class, not a struct, so it can be lazily loaded and shared (the missing glyph in a font is
/// always used for several characters).
public class Glyph {
    
    /// The width of a character is the distance from the origin of the character to the origin of the next one.
    public var width = 0
    
    ///  The offset is the position of the character bitmap relative to the character origin. Positive towards the right.
    public var imageOffset = 0
    
    /// Top of image, from the baseline
    public var imageTop = 0
    
    /// The image of the character
    public var image: MaskedImage? = nil
    
}
