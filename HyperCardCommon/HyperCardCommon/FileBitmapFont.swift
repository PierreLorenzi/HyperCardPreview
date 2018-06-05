//
//  FileBitmapFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Subclass of BitmapFont with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileBitmapFont: BitmapFont {
    
    private let block: BitmapFontResourceBlock
    
    public init(block: BitmapFontResourceBlock) {
        self.block = block
        
        super.init()
        
        /* Read now the scalar fields */
        self.maximumWidth = block.readMaximumWidth()
        self.maximumKerning = block.readMaximumKerning()
        self.fontRectangleWidth = block.readFontRectangleWidth()
        self.fontRectangleHeight = block.readFontRectangleHeight()
        self.maximumAscent = block.readMaximumAscent()
        self.maximumDescent = block.readMaximumDescent()
        self.leading = block.readLeading()
    }
    
    private var glyphsLoaded = false
    override public var glyphs: [Glyph] {
        get {
            if !glyphsLoaded {
                super.glyphs = loadGlyphs()
                glyphsLoaded = true
            }
            return super.glyphs
        }
        set {
            glyphsLoaded = true
            super.glyphs = newValue
        }
    }
    
    private func loadGlyphs() -> [Glyph] {
        
        var glyphs = [Glyph]()
        
        /* Gather some data */
        let lastCharacterCode = block.readLastCharacterCode()
        let firstCharacterCode = block.readFirstCharacterCode()
        let maximumAscent = block.readMaximumAscent()
        let maximumKerning = block.readMaximumKerning()
        let fontRectangleHeight = block.readFontRectangleHeight()
        let widthTable = block.readWidthTable()
        let offsetTable = block.readOffsetTable()
        let bitmapLocationTable = block.readBitmapLocationTable()
        let bitImage = block.readBitImage()
        
        /* The special glyph is used outside the character bounds. It is the last in the font */
        let specialGlyphIndex = lastCharacterCode - firstCharacterCode + 1
        let specialGlyph = Glyph(maximumAscent: maximumAscent, maximumKerning: maximumKerning, fontRectangleHeight: fontRectangleHeight, widthTable: widthTable, offsetTable: offsetTable, bitmapLocationTable: bitmapLocationTable, bitImage: bitImage, index: specialGlyphIndex)
        
        for index in 0..<256 {
            
            /* Outside of the bounds, use the special glyph */
            guard index >= firstCharacterCode && index <= lastCharacterCode else {
                glyphs.append(specialGlyph)
                continue
            }
            
            /* Build the glyph */
            let glyph = Glyph(maximumAscent: maximumAscent, maximumKerning: maximumKerning, fontRectangleHeight: fontRectangleHeight, widthTable: widthTable, offsetTable: offsetTable, bitmapLocationTable: bitmapLocationTable, bitImage: bitImage, index: index)
            glyphs.append(glyph)
            
        }
        
        return glyphs
    }
    
}

