//
//  FileBitmapFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class FileBitmapFont: BitmapFont {

    private let block: BitmapFontResourceBlock
    
    public init(block: BitmapFontResourceBlock) {
        self.block = block
    }
    
    private var maximumWidthLoaded = false
    override public var maximumWidth: Int {
        get {
            if !maximumWidthLoaded {
                super.maximumWidth = block.maximumWidth
                maximumWidthLoaded = true
            }
            return super.maximumWidth
        }
        set {
            super.maximumWidth = newValue
        }
    }
    
    private var maximumKerningLoaded = false
    override public var maximumKerning: Int {
        get {
            if !maximumKerningLoaded {
                super.maximumKerning = block.maximumKerning
                maximumKerningLoaded = true
            }
            return super.maximumKerning
        }
        set {
            super.maximumKerning = newValue
        }
    }
    
    private var fontRectangleWidthLoaded = false
    override public var fontRectangleWidth: Int {
        get {
            if !fontRectangleWidthLoaded {
                super.fontRectangleWidth = block.fontRectangleWidth
                fontRectangleWidthLoaded = true
            }
            return super.fontRectangleWidth
        }
        set {
            super.fontRectangleWidth = newValue
        }
    }
    
    private var fontRectangleHeightLoaded = false
    override public var fontRectangleHeight: Int {
        get {
            if !fontRectangleHeightLoaded {
                super.fontRectangleHeight = block.fontRectangleHeight
                fontRectangleHeightLoaded = true
            }
            return super.fontRectangleHeight
        }
        set {
            super.fontRectangleHeight = newValue
        }
    }
    
    private var maximumAscentLoaded = false
    override public var maximumAscent: Int {
        get {
            if !maximumAscentLoaded {
                super.maximumAscent = block.maximumAscent
                maximumAscentLoaded = true
            }
            return super.maximumAscent
        }
        set {
            super.maximumAscent = newValue
        }
    }
    
    private var maximumDescentLoaded = false
    override public var maximumDescent: Int {
        get {
            if !maximumDescentLoaded {
                super.maximumDescent = block.maximumDescent
                maximumDescentLoaded = true
            }
            return super.maximumDescent
        }
        set {
            super.maximumDescent = newValue
        }
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
