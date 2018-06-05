//
//  VectorFontConverting.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Foundation


public enum VectorFontConverting {
    
    /// Converts a Core Text font to a bitmap font
    public static func convertVectorFont(_ font: CTFont) -> BitmapFont {
        return buildFontFromVector(font)
    }
    
}


private func buildFontFromVector(_ vectorFont: CTFont) -> BitmapFont {
    
    let font = BitmapFont()
    
    /* Check if the CT Font has an integer width table */
    let integerWidthTable: HdmxTableRecord? = findIntegerWidths(inVectorFont: vectorFont)
    
    /* Measures */
    let boundingBox = CTFontGetBoundingBox(vectorFont)
    font.maximumWidth = integerWidthTable?.maximumWidth ?? Int(round(boundingBox.origin.x + boundingBox.size.width))
    font.maximumKerning = Int(round(boundingBox.origin.x))
    font.maximumAscent = Int(round(CTFontGetAscent(vectorFont)))
    font.maximumDescent = Int(round(CTFontGetDescent(vectorFont)))
    font.fontRectangleWidth = Int(round(boundingBox.size.width))
    font.fontRectangleHeight = Int(round(boundingBox.size.height))
    
    /* Glyphs */
    var glyphs = [Glyph]()
    
    for i in 0..<256 {
        let unicodeCharacter = UnicharMacOSRoman[i]
        let singletonCharacter = [unicodeCharacter]
        var vectorGlyphSingleton: [CGGlyph] = [CGGlyph(0)]
        let result = CTFontGetGlyphsForCharacters(vectorFont, singletonCharacter, &vectorGlyphSingleton, 1)
        if !result || vectorGlyphSingleton[0] == CGGlyph(0) {
            glyphs.append(Glyph())
        }
        else {
            let integerWidth = integerWidthTable?.widths[Int(vectorGlyphSingleton[0])]
            let glyph = Glyph(font: vectorFont, glyph: vectorGlyphSingleton[0], integerWidth: integerWidth)
            glyphs.append(glyph)
        }
    }
    
    font.glyphs = glyphs
    
    return font
}

private func findIntegerWidths(inVectorFont vectorFont: CTFont) -> HdmxTableRecord? {
    
    /* Get the integer width table */
    guard let cfdata = CTFontCopyTable(vectorFont, CTFontTableTag(kCTFontTableHdmx), CTFontTableOptions(rawValue: 0)) else {
        return nil
    }
    
    /* Get the font sizes present in the table */
    let data = cfdata as NSData as Data
    let header = HdmxTableReader.readHeader(inData: data)
    let fontSizes = HdmxTableReader.listFontSizes(recordCount: header.recordCount, recordSize: header.recordSize, inData: data)
    
    /* Check if the right font size is present */
    let vectorFontSize = Int(CTFontGetSize(vectorFont))
    guard let index = fontSizes.index(where: { $0 == vectorFontSize }) else {
        return nil
    }
    
    /* Return the integer width table */
    return HdmxTableReader.readRecord(atIndex: index, size: header.recordSize, inData: data)
    
}


public extension Glyph {
    
    public convenience init(font: CTFont, glyph: CGGlyph, integerWidth: Int?) {
        
        self.init()
        
        /* Get metrics */
        let vectorGlyphSingleton = [glyph]
        let advance = CTFontGetAdvancesForGlyphs(font, CTFontOrientation.horizontal, vectorGlyphSingleton, nil, 1)
        let boundingRect = CTFontGetBoundingRectsForGlyphs(font, CTFontOrientation.horizontal, vectorGlyphSingleton, nil, 1)
        
        /* Adjust scalar fields */
        self.width = integerWidth ?? Int(ceil(advance))
        self.imageOffset = Int(round(boundingRect.origin.x) - 1)
        self.imageTop = Int(round(boundingRect.origin.y + boundingRect.size.height) + 1)
        self.imageWidth = Int(round(boundingRect.size.width) + 2)
        self.imageHeight = Int(round(boundingRect.size.height) + 2)
        
        /* Lazy-load image */
        self.imageProperty.lazyCompute { () -> MaskedImage? in
            return self.loadImage(vectorFont: font, vectorGlyph: glyph)
        }
        
    }
    
    private func loadImage(vectorFont: CTFont, vectorGlyph: CGGlyph) -> MaskedImage? {
        
        if imageWidth == 0 || imageHeight == 0 {
            return nil
        }
        
        /* Build a graphic context where to draw the glyph */
        guard let context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        context.setShouldAntialias(false)
        
        /* Draw the glyph */
        var glyphs = [vectorGlyph]
        var positions = [CGPoint(x: Double(-self.imageOffset), y: Double(self.imageHeight-self.imageTop))]
        CTFontDrawGlyphs(vectorFont, &glyphs, &positions, 1, context)
        
        /* Convert the image to 1-bit */
        let image: CGImage = context.makeImage()!
        let imageRep = NSBitmapImageRep.init(cgImage: image)
        let maskedImage = MaskedImage(representation: imageRep)
        
        return maskedImage
        
    }
    
}

/// A map of the Unicode values of the Mac OS Roman encoding
public let UnicharMacOSRoman: [UniChar] = [
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
    0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
    0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
    0x00C4, 0x00C5, 0x00C7, 0x00C9, 0x00D1, 0x00D6, 0x00DC, 0x00E1, 0x00E0, 0x00E2, 0x00E4, 0x00E3, 0x00E5, 0x00E7, 0x00E9, 0x00E8,
    0x00EA, 0x00EB, 0x00ED, 0x00EC, 0x00EE, 0x00EF, 0x00F1, 0x00F3, 0x00F2, 0x00F4, 0x00F6, 0x00F5, 0x00FA, 0x00F9, 0x00FB, 0x00FC,
    0x2020, 0x00B0, 0x00A2, 0x00A3, 0x00A7, 0x2022, 0x00B6, 0x00DF, 0x00AE, 0x00A9, 0x2122, 0x00B4, 0x00A8, 0x2260, 0x00C6, 0x00D8,
    0x221E, 0x00B1, 0x2264, 0x2265, 0x00A5, 0x00B5, 0x2202, 0x2211, 0x220F, 0x03C0, 0x222B, 0x00AA, 0x00BA, 0x03A9, 0x00E6, 0x00F8,
    0x00BF, 0x00A1, 0x00AC, 0x221A, 0x0192, 0x2248, 0x2206, 0x00AB, 0x00BB, 0x2026, 0x00A0, 0x00C0, 0x00C3, 0x00D5, 0x0152, 0x0153,
    0x2013, 0x2014, 0x201C, 0x201D, 0x2018, 0x2019, 0x00F7, 0x25CA, 0x00FF, 0x0178, 0x2044, 0x20AC, 0x2039, 0x203A, 0xFB01, 0xFB02,
    0x2021, 0x00B7, 0x201A, 0x201E, 0x2030, 0x00C2, 0x00CA, 0x00C1, 0x00CB, 0x00C8, 0x00CD, 0x00CE, 0x00CF, 0x00CC, 0x00D3, 0x00D4,
    0xF8FF, 0x00D2, 0x00DA, 0x00DB, 0x00D9, 0x0131, 0x02C6, 0x02DC, 0x00AF, 0x02D8, 0x02D9, 0x02DA, 0x00B8, 0x02DD, 0x02DB, 0x02C7
]
