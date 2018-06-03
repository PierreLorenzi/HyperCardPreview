//
//  FontResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// Parsed bitmap font resource
public class BitmapFontResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "NFNT")!
    }
    
    /// Whether the font resource contains an image height table
    public func readContainsImageHeightTable() -> Bool {
        return data.readFlag(at: 0, bitOffset: 0)
    }
    
    /// Whether the font resource contains a glyph-width table
    public func readContainsGlyphWidthTable() -> Bool {
        return data.readFlag(at: 0, bitOffset: 1)
    }
    
    /// An integer value that specifies the ASCII character code of the first glyph in the font
    public func readFirstCharacterCode() -> Int {
        return data.readUInt16(at: 0x2)
    }
    
    /// An integer value that specifies the ASCII character code of the last glyph in the font
    public func readLastCharacterCode() -> Int {
        return data.readUInt16(at: 0x4)
    }
    
    /// An integer value that specifies the maximum width of the widest glyph in the font, in pixels
    public func readMaximumWidth() -> Int {
        return data.readUInt16(at: 0x6)
    }
    
    /// An integer value that specifies the distance from the font rectangle's glyph origin to the left edge of the font rectangle, in pixels. If a glyph in the font kerns to the left, the amount is represented as a negative number. If the glyph origin lies on the left edge of the font rectangle, the value of the kernMax field is 0.
    public func readMaximumKerning() -> Int {
        return data.readSInt16(at: 0x8)
    }
    
    /// If this font has very large tables and this value is positive, this value is the high word of the offset to the width/offset table. If this value is negative, it is the negative of the descent and is not used by the Font Manager
    public func readNegatedDescentValue() -> Int {
        return data.readUInt16(at: 0xA)
    }
    
    /// An integer value that specifies the width, in pixels, of the image created if all the glyphs in the font were superimposed at their glyph origins
    public func readFontRectangleWidth() -> Int {
        return data.readUInt16(at: 0xC)
    }
    
    /// An integer value that specifies the height, in pixels, of the image created if all the glyphs in the font were superimposed at their glyph origins. This value equals the sum of the maximum ascent and maximum descent measurements for the font
    public func readFontRectangleHeight() -> Int {
        return data.readUInt16(at: 0xE)
    }
    
    /// An integer value that specifies the offset to the offset/width table from this point in the font record, in words. If this font has very large tables, this value is only the low word of the offset and the negated descent value is the high word
    public func readWidthOffsetTableOffset() -> Int {
        return data.readUInt16(at: 0x10)
    }
    
    /// An integer value that specifies the maximum ascent measurement for the entire font, in pixels. The ascent is the distance from the glyph origin to the top of the font rectangle
    public func readMaximumAscent() -> Int {
        return data.readUInt16(at: 0x12)
    }
    
    /// An integer value that specifies the maximum descent measurement for the entire font, in pixels. The descent is the distance from the glyph origin to the bottom of the font rectangle
    public func readMaximumDescent() -> Int {
        return data.readUInt16(at: 0x14)
    }
    
    /// An integer value that specifies the leading measurement for the entire font, in pixels. Leading is the distance from the descent line of one line of single-spaced text to the ascent line of the next line of text
    public func readLeading() -> Int {
        return data.readUInt16(at: 0x16)
    }
    
    /// An integer value that specifies the width of the bit image, in words. This is the width of each glyph's bit image as a number of words
    public func readBitImageRowWidth() -> Int {
        return data.readUInt16(at: 0x18)
    }
    
    /// The bit image of the glyphs in the font. The glyph images of every defined glyph in the font are placed sequentially in order of increasing ASCII code. The bit image is one pixel image with no undefined stretches that has a height given by the value of the font rectangle element and a width given by the value of the bit image row width element. The image is padded at the end with extra pixels to make its length a multiple of 16.
    public func readBitImage() -> Image {
        let bitImageRowWidth = self.readBitImageRowWidth()
        let fontRectangleHeight = self.readFontRectangleHeight()
        return Image(data: data.sharedData, offset: data.offset + 0x1A, width: bitImageRowWidth*16, height: fontRectangleHeight)
    }
    
    private func computeBitImageSize() -> Int {
        let bitImageRowWidth = self.readBitImageRowWidth()
        let fontRectangleHeight = self.readFontRectangleHeight()
        return bitImageRowWidth * 2 *  fontRectangleHeight
    }
    
    private func computeBitmapLocationTableSize() -> Int {
        let characterCount = self.computeCharacterCount()
        return (characterCount + 1) * 2
    }
    
    private func computeCharacterCount() -> Int {
        let lastCharacterCode = self.readLastCharacterCode()
        let firstCharacterCode = self.readFirstCharacterCode()
        return lastCharacterCode - firstCharacterCode + 2
    }
    
    /// Bitmap location table. For every glyph in the font, this table contains a word that specifies the bit offset to the location of the bitmap for that glyph in the bit image table. If a glyph is missing from the font, its entry contains the same value for its location as the entry for the next glyph. The missing glyph is the last glyph of the bit image for that font. The last word of the table contains the offset to one bit beyond the end of the bit image. You can determine the image width of each glyph from the bitmap location table by subtracting the bit offset to that glyph from the bit offset to the next glyph in the table.
    public func readBitmapLocationTable() -> [Int] {
        let characterCount = self.computeCharacterCount()
        let tableCount = characterCount + 1
        let bitImageSize = self.computeBitImageSize()
        var locations = [Int](repeating: 0, count: tableCount)
        let startOffset = 0x1A + bitImageSize
        for i in 0..<tableCount {
            let value = data.readUInt16(at: startOffset + 2 * i)
            locations[i] = value
        }
        return locations
    }
    
    /// For every character, the horizontal distance from the glyph origin to the left edge of the bit image of the glyph, in pixels. If it is negative, the glyph origin
    /// is to the right of the glyph image's left edge, meaning the glyph kerns to the left.
    /// If it is positive, the origin is to the left of the image's left edge. If the sum equals zero, the glyph origin corresponds with the left edge of the bit image
    public func readOffsetTable() -> [Int] {
        let count = self.computeCharacterCount()
        let bitImageSize = self.computeBitImageSize()
        let bitmapLocationTableSize = self.computeBitmapLocationTableSize()
        var widths = [Int](repeating: 0, count: count)
        let startOffset = 0x1A + bitImageSize + bitmapLocationTableSize
        for i in 0..<count {
            let value = data.readSInt16(at: startOffset + 2 * i)
            if value == -1 {
                continue
            }
            widths[i] = value >> 8
        }
        return widths
    }
    
    /// For every character, the width, that is, length in pixels from origin to origin of next glyph
    public func readWidthTable() -> [Int] {
        let count = self.computeCharacterCount()
        let bitImageSize = self.computeBitImageSize()
        let bitmapLocationTableSize = self.computeBitmapLocationTableSize()
        var widths = [Int](repeating: 0, count: count)
        let startOffset = 0x1A + bitImageSize + bitmapLocationTableSize
        for i in 0..<count {
            let value = data.readSInt16(at: startOffset + 2 * i)
            if value == -1 {
                continue
            }
            widths[i] = value & 255
        }
        return widths
    }
    
}

/// A sub-class for the 'FONT' resources. They have the same structure and they may be also present
public class BitmapFontResourceBlockOld: BitmapFontResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "FONT")!
}

}

