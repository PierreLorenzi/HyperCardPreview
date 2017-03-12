//
//  Font.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 18/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/**
    A bitmap font. Contains general measures and character tables.

    The character images are all aligned in one single bitmap.

    The font tables have a supplementary character, the missing glyph, to be drawned when
    a character is not included in the font.
*/
public class BitmapFont {
    
    /** Maximum width of the characters. */
    public var maximumWidth: Int            = 0
    
    /** Maximum kerning of the characters.
    The kerning of a character is the number of pixels of that character on the left of the origin.
    It is equal to zero if the whole character lies to the right of the origin. */
    public var maximumKerning: Int          = 0
    
    /** The maximum width of a character bitmap */
    public var fontRectangleWidth: Int      = 0
    
    /** The maximum height of a character bitmap */
    public var fontRectangleHeight: Int     = 0
    
    /** The maximum ascent of the characters.
    The ascent is the number of pixels above the baseline. */
    public var maximumAscent: Int           = 0
    
    /** The maximum descent of the characters.
    The descent is the number of pixels below the baseline. */
    public var maximumDescent: Int          = 0
    
    /** Character data, the indices always range from 0 to 255 */
    public var glyphs: [Glyph] = []
    
    public func computeSizeOfString(_ string: HString) -> Int {
        var size = 0
        for i in 0..<string.length {
            let characterIndex = Int(string[i])
            let glyph = glyphs[characterIndex]
            size += glyph.width
        }
        return size
    }
    
}
