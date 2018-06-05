//
//  Font.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 18/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// A bitmap font. Contains general measures and a table of the glyphs.
public class BitmapFont {
    
    /// Maximum width of the characters.
    public var maximumWidth = 0
    
    /// Maximum kerning of the characters.
    /// <p>
    /// The kerning of a character is the number of pixels of that character on the left of the origin.
    /// It is equal to zero if the whole character lies to the right of the origin.
    public var maximumKerning = 0
    
    /// The maximum width of the character bitmaps
    public var fontRectangleWidth = 0
    
    /// The maximum height of the character bitmaps
    public var fontRectangleHeight = 0
    
    /// The maximum ascent of the characters.
    /// <p>
    /// The ascent is the number of pixels above the baseline.
    public var maximumAscent = 0
    
    /// The maximum descent of the characters.
    /// <p>
    /// The descent is the number of pixels below the baseline.
    public var maximumDescent = 0
    
    /// Leading.
    /// <p>
    /// An integer value that specifies the leading measurement for the entire font, in pixels. Leading is the distance from the descent line of one line of single-spaced text to the ascent line of the next line of text. This value is represented by the leading field in the FontRec data type.
    public var leading = 0
    
    /// The glyphs. The indexes range from 0 to 255
    public var glyphs: [Glyph] {
        get { return self.glyphsProperty.value }
        set { self.glyphsProperty.value = newValue }
    }
    public var glyphsProperty = Property<[Glyph]>([])
    
    /// Compute the width of a string in that font, in pixels, from the origin of the first
    /// glyph to the origin of the glyph after the last glyph
    public func computeSizeOfString(_ string: HString, index: Int = 0, length possibleLength: Int? = nil) -> Int {
        var size = 0
        let length = possibleLength ?? string.length - index
        for i in index..<(index + length) {
            let characterIndex = Int(string[i])
            let glyph = glyphs[characterIndex]
            size += glyph.width
        }
        return size
    }
    
}
