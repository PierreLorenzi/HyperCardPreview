//
//  FileBitmapFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


extension BitmapFont: ResourceContent {
    
    /// Loads a bitmap font from the data of a NFNT or FONT resource
    public init(loadFromData data: DataRange) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.maximumWidth = data.readUInt16(at: 0x6)
        self.maximumKerning = data.readSInt16(at: 0x8)
        self.fontRectangleWidth = data.readUInt16(at: 0xC)
        self.fontRectangleHeight = data.readUInt16(at: 0xE)
        self.maximumAscent = data.readUInt16(at: 0x12)
        self.maximumDescent = data.readUInt16(at: 0x14)
        self.leading = data.readUInt16(at: 0x16)
        
        /* Lazy load the glyphs */
        self.glyphsProperty.lazyCompute { () -> [Glyph] in
            return BitmapFont.loadGlyphs(in: data)
        }
    }
    
    private static func loadGlyphs(in data: DataRange) -> [Glyph] {
        
        var glyphs = [Glyph]()
        
        /* Gather some data */
        let firstCharacterCode = data.readUInt16(at: 0x2)
        let lastCharacterCode = data.readUInt16(at: 0x4)
        let maximumAscent = data.readUInt16(at: 0x12)
        let maximumKerning = data.readSInt16(at: 0x8)
        let fontRectangleHeight = data.readUInt16(at: 0xE)
        let bitImageRowWidth = data.readUInt16(at: 0x18)
        
        /* Compute some values */
        let characterCount = lastCharacterCode - firstCharacterCode + 2
        let bitImageSize = bitImageRowWidth * 2 * fontRectangleHeight
        let bitmapLocationTableSize = (characterCount + 1) * 2
        
        /* Read the font tables */
        let widthTable = BitmapFont.readWidthTable(in: data, characterCount: characterCount, bitImageSize: bitImageSize, bitmapLocationTableSize: bitmapLocationTableSize)
        let offsetTable = BitmapFont.readOffsetTable(in: data, characterCount: characterCount, bitImageSize: bitImageSize, bitmapLocationTableSize: bitmapLocationTableSize)
        let bitmapLocationTable = BitmapFont.readBitmapLocationTable(in: data, characterCount: characterCount, bitImageSize: bitImageSize)
        
        // The bit image of the glyphs in the font. The glyph images of every defined glyph in the font are placed sequentially in order of increasing ASCII code. The bit image is one pixel image with no undefined stretches that has a height given by the value of the font rectangle element and a width given by the value of the bit image row width element. The image is padded at the end with extra pixels to make its length a multiple of 16.
        let loadBitImage = { () -> Image in
            return Image(data: data.sharedData, offset: data.offset + 0x1A, width: bitImageRowWidth*16, height: fontRectangleHeight) }
        
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
    
    /// For every character, the width, that is, length in pixels from origin to origin of next glyph
    private static func readWidthTable(in data: DataRange, characterCount: Int, bitImageSize: Int, bitmapLocationTableSize: Int) -> [Int] {
        
        var widths = [Int](repeating: 0, count: characterCount)
        
        let startOffset = 0x1A + bitImageSize + bitmapLocationTableSize
        
        for i in 0..<characterCount {
            
            let value = data.readSInt16(at: startOffset + 2 * i)
            if value == -1 {
                continue
            }
            
            widths[i] = value & 255
        }
        
        return widths
    }
    
    /// For every character, the horizontal distance from the glyph origin to the left edge of the bit image of the glyph, in pixels. If it is negative, the glyph origin
    /// is to the right of the glyph image's left edge, meaning the glyph kerns to the left.
    /// If it is positive, the origin is to the left of the image's left edge. If the sum equals zero, the glyph origin corresponds with the left edge of the bit image
    private static func readOffsetTable(in data: DataRange, characterCount: Int, bitImageSize: Int, bitmapLocationTableSize: Int) -> [Int] {
        
        var widths = [Int](repeating: 0, count: characterCount)
        
        let startOffset = 0x1A + bitImageSize + bitmapLocationTableSize
        
        for i in 0..<characterCount {
            
            let value = data.readSInt16(at: startOffset + 2 * i)
            if value == -1 {
                continue
            }
            
            widths[i] = value >> 8
        }
        
        return widths
    }
    
    /// Bitmap location table. For every glyph in the font, this table contains a word that specifies the bit offset to the location of the bitmap for that glyph in the bit image table. If a glyph is missing from the font, its entry contains the same value for its location as the entry for the next glyph. The missing glyph is the last glyph of the bit image for that font. The last word of the table contains the offset to one bit beyond the end of the bit image. You can determine the image width of each glyph from the bitmap location table by subtracting the bit offset to that glyph from the bit offset to the next glyph in the table.
    private static func readBitmapLocationTable(in data: DataRange, characterCount: Int, bitImageSize: Int) -> [Int] {
        
        let tableCount = characterCount + 1
        let startOffset = 0x1A + bitImageSize
        
        var locations = [Int](repeating: 0, count: tableCount)
        
        for i in 0..<tableCount {
            
            let value = data.readUInt16(at: startOffset + 2 * i)
            locations[i] = value
        }
        
        return locations
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


