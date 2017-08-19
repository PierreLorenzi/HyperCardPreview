//
//  FileBitmapFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension BitmapFont {
    
    public convenience init(block: BitmapFontResourceBlock) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.maximumWidth = block.maximumWidth
        self.maximumKerning = block.maximumKerning
        self.fontRectangleWidth = block.fontRectangleWidth
        self.fontRectangleHeight = block.fontRectangleHeight
        self.maximumAscent = block.maximumAscent
        self.maximumDescent = block.maximumDescent
        
        /* Enable lazy initialization */
        
        /* glyphs */
        self.glyphsProperty.observers.append(LazyInitializer(property: self.glyphsProperty, initialization: {
            return self.loadGlyphs(block: block)
        }))
        
    }
    
    private func loadGlyphs(block: BitmapFontResourceBlock) -> [Glyph] {
        
        var glyphs = [Glyph]()
        
        /* The special glyph is used outside the character bounds. It is the last in the font */
        let specialGlyph = Glyph(font: block, index: block.lastCharacterCode - block.firstCharacterCode + 1)
        
        for index in 0..<256 {
            
            /* Outside of the bounds, use the special glyph */
            guard index >= block.firstCharacterCode && index <= block.lastCharacterCode else {
                glyphs.append(specialGlyph)
                continue
            }
            
            /* Build the glyph */
            let glyph = Glyph(font: block, index: index)
            glyphs.append(glyph)
            
        }
        
        return glyphs
    }
    
}

