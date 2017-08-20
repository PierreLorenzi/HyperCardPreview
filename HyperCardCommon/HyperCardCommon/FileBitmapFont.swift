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
        self.maximumWidth = block.maximumWidth
        self.maximumKerning = block.maximumKerning
        self.fontRectangleWidth = block.fontRectangleWidth
        self.fontRectangleHeight = block.fontRectangleHeight
        self.maximumAscent = block.maximumAscent
        self.maximumDescent = block.maximumDescent
        self.leading = block.leading
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
        
        /* The special glyph is used outside the character bounds. It is the last in the font */
        let specialGlyph = FileGlyph(font: block, index: block.lastCharacterCode - block.firstCharacterCode + 1)
        
        for index in 0..<256 {
            
            /* Outside of the bounds, use the special glyph */
            guard index >= block.firstCharacterCode && index <= block.lastCharacterCode else {
                glyphs.append(specialGlyph)
                continue
            }
            
            /* Build the glyph */
            let glyph = FileGlyph(font: block, index: index)
            glyphs.append(glyph)
            
        }
        
        return glyphs
    }
    
}

