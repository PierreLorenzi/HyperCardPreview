//
//  FileBitmapFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension BitmapFont {
    
    /// Loads a bitmap font from the data of a NFNT or FONT resource
    convenience init(loadFromData data: DataRange) {
        
        let reader = BitmapFontResourceReader(data: data)
        
        self.init()
        
        /* Read now the scalar fields */
        self.maximumWidth = reader.readMaximumWidth()
        self.maximumKerning = reader.readMaximumKerning()
        self.fontRectangleWidth = reader.readFontRectangleWidth()
        self.fontRectangleHeight = reader.readFontRectangleHeight()
        self.maximumAscent = reader.readMaximumAscent()
        self.maximumDescent = reader.readMaximumDescent()
        self.leading = reader.readLeading()
        
        /* Lazy load the glyphs */
        self.glyphsProperty.lazyCompute { () -> [Glyph] in
            return BitmapFont.loadGlyphs(reader: reader)
        }
    }
    
    private static func loadGlyphs(reader: BitmapFontResourceReader) -> [Glyph] {
        
        var glyphs = [Glyph]()
        
        /* Gather some data */
        let lastCharacterCode = reader.readLastCharacterCode()
        let firstCharacterCode = reader.readFirstCharacterCode()
        let maximumAscent = reader.readMaximumAscent()
        let maximumKerning = reader.readMaximumKerning()
        let fontRectangleHeight = reader.readFontRectangleHeight()
        let widthTable = reader.readWidthTable()
        let offsetTable = reader.readOffsetTable()
        let bitmapLocationTable = reader.readBitmapLocationTable()
        let bitImageProperty = Property<Image> { () -> Image in
            return reader.readBitImage()
        }
        let loadBitImage = { () -> Image in return bitImageProperty.value }
        
        /* The special glyph is used outside the character bounds. It is the last in the font */
        let specialGlyphIndex = lastCharacterCode - firstCharacterCode + 1
        let specialGlyph = Glyph(maximumAscent: maximumAscent, maximumKerning: maximumKerning, fontRectangleHeight: fontRectangleHeight, width: widthTable[specialGlyphIndex], offset: offsetTable[specialGlyphIndex], startImageOffset: bitmapLocationTable[specialGlyphIndex], endImageOffset: bitmapLocationTable[specialGlyphIndex+1], loadBitImage: loadBitImage)
        
        for index in 0..<256 {
            
            /* Outside of the bounds, use the special glyph */
            guard index >= firstCharacterCode && index <= lastCharacterCode else {
                glyphs.append(specialGlyph)
                continue
            }
            
            /* Build the glyph */
            let glyph = Glyph(maximumAscent: maximumAscent, maximumKerning: maximumKerning, fontRectangleHeight: fontRectangleHeight, width: widthTable[index], offset: offsetTable[index], startImageOffset: bitmapLocationTable[index], endImageOffset: bitmapLocationTable[index+1], loadBitImage: loadBitImage)
            glyphs.append(glyph)
            
        }
        
        return glyphs
    }
    
}

/// Glyph with lazy loading from a file
private extension Glyph {
    
    convenience init(maximumAscent: Int, maximumKerning: Int, fontRectangleHeight: Int, width: Int, offset: Int, startImageOffset: Int, endImageOffset: Int, loadBitImage: @escaping () -> Image) {
        
        self.init()
        
        self.width = width
        self.imageOffset = maximumKerning + offset
        self.imageTop = maximumAscent
        self.imageWidth = endImageOffset - startImageOffset
        self.imageHeight = fontRectangleHeight
        self.isThereImage = (endImageOffset > startImageOffset)
        self.imageProperty.lazyCompute { () -> MaskedImage? in
            return Glyph.loadImage(startOffset: startImageOffset, endOffset: endImageOffset, loadBitImage: loadBitImage)
        }
    }
    
    private static func loadImage(startOffset: Int, endOffset: Int, loadBitImage: () -> Image) -> MaskedImage? {
        
        /* If the image has a null width, there is no image */
        guard endOffset > startOffset else {
            return nil
        }
        
        /* Load the image */
        let bitImage = loadBitImage()
        let drawing = Drawing(width: endOffset - startOffset, height: bitImage.height)
        drawing.drawImage(bitImage, position: Point(x: 0, y: 0), rectangleToDraw: Rectangle(top: 0, left: startOffset, bottom: bitImage.height, right: endOffset))
        
        return MaskedImage(image: drawing.image)
        
    }
    
}


