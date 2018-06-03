//
//  FontFamilyResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//



/// Parsed font family resource
/// <p>
/// A font family represents what the user perceives as a font. It contains a list of
/// bitmap fonts and vector fonts to use for different sizes and styles.
/// <p>
/// All the sizes and styles don't need to be present. If one is missing, it is generated.
public class FontFamilyResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "FOND")!
    }
    
    /// A font record, mapping a size and a style to a font
    public struct FontAssociation {
        
        /// The size of the font (if 0, the font is vector, elsewhere the font is bitmap)
        public let size: Int
        
        /// The style of the font
        public let style: TextStyle
        
        /// The ID of the font resource
        public let resourceIdentifier: Int
    }
    
    private func readFraction(at offset: Int) -> Double {
        let bits = data.readUInt16(at: offset)
        
        /* Check sign bit */
        let negative = ((bits >> 15) == 1)
        if negative {
            
            /* Negative can be either the positive value with the sign bit, either a negative value. Apple
             doesn't tell the convention in the spec so people made as they wished. So we infer the convention by looking at the next bit. */
            
            let secondBit = ((bits >> 14) & 1 == 1)
            if secondBit {
                return Double(bits - Int(UInt16.max) - 1) / Double(1 << 12)
            }
            else {
                return -Double(bits & 0x7FFF) / Double(1 << 12)
            }
            
        }
        
        /* No problem, the value is positive */
        return Double(bits) / Double(1 << 12)
    }
    
    /// Whether the font family contains a glyph-width table
    public func readContainsGlyphWidthTable() -> Bool {
        return data.readFlag(at: 0, bitOffset: 1)
    }
    
    ///This bit is set to 1 if the font family should use integer extra width for stylistic variations. If not set, the font family should compute the fixed-point extra width from the family style-mapping table, but only if the FractEnable global variable has a value of TRUE.
    public func readUseIntegerExtraWidth() -> Bool {
        return data.readFlag(at: 0, bitOffset: 13)
    }
    
    
    /// Whether the fonts are fixed-width
    public func readIsFixedWidth() -> Bool {
        return data.readFlag(at: 0, bitOffset: 15)
    }
    
    /// ID of the font family
    public func readFontIdentifier() -> Int {
        return data.readUInt16(at: 0x2)
    }
    
    /// The ASCII character code of the first glyph in the font family
    public func readFirstCharacterCode() -> Int {
        return data.readUInt16(at: 0x4)
    }
    
    /// The ASCII character code of the last glyph in the font family
    public func readLastCharacterCode() -> Int {
        return data.readUInt16(at: 0x6)
    }
    
    /// The maximum ascent measurement for a one-point font of the font family
    public func readMaximumAscent() -> Double {
        return self.readFraction(at: 0x8)
    }
    
    /// The maximum descent measurement for a one-point font of the font family
    public func readMaximumDescent() -> Double {
        return self.readFraction(at: 0xA)
    }
    
    /// The maximum leading for a 1-point font of the font family
    public func readMaximumLeading() -> Double {
        return self.readFraction(at: 0xC)
    }
    
    /// The maximum glyph width of any glyph in a one-point font of the font family
    public func readMaximumGlyphWidth() -> Double {
        return self.readFraction(at: 0xE)
    }
    
    /// The offset to the family glyph-width table from the beginning of the font family resource to the beginning of the table, in bytes
    public func readGlyphWidthTableOffset() -> Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// The offset to the beginning of the kerning table from the beginning of the 'FOND' resource, in bytes
    public func readKerningTableOffset() -> Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// The offset to the style-mapping table from the beginning of the font family resource to the beginning of the table, in bytes
    public func readStyleMappingTableOffset() -> Int {
        return data.readUInt32(at: 0x18)
    }
    
    /// Each value indicates the extra width, in pixels, that would be added to the glyphs of a 1-point font in this font family after a stylistic variation has been applied
    public func readStyleProperties() -> FontStyleProperties {
        
        let plainExtraWidth = self.readFraction(at: 0x1C)
        let boldExtraWidth = self.readFraction(at: 0x1E)
        let italicExtraWidth = self.readFraction(at: 0x20)
        let underlineExtraWidth = self.readFraction(at: 0x22)
        let outlineExtraWidth = self.readFraction(at: 0x24)
        let shadowExtraWidth = self.readFraction(at: 0x26)
        let condensedExtraWidth = self.readFraction(at: 0x28)
        let extendedExtraWidth = self.readFraction(at: 0x2A)
        
        return FontStyleProperties(plainExtraWidth: plainExtraWidth, boldExtraWidth: boldExtraWidth, italicExtraWidth: italicExtraWidth, underlineExtraWidth: underlineExtraWidth, outlineExtraWidth: outlineExtraWidth, shadowExtraWidth: shadowExtraWidth, condensedExtraWidth: condensedExtraWidth, extendedExtraWidth: extendedExtraWidth)
    }
    
    /// An integer value that specifies the version number of the font family resource, which indicates whether certain tables are available
    /// <p>
    /// Possible values are:
    /// <p>
    /// 0	Created by the Macintosh system software. The font family resource will not have the glyph-width tables and the fields will contain 0.
    /// <p>
    /// 1	Original format as designed by the font developer. This font family record probably has the width tables and most of the fields are filled.
    /// <p>
    /// 2	This record may contain the offset and bounding-box tables.
    /// <p>
    /// 3	This record definitely contains the offset and bounding-box tables.
    public func readVersion() -> Int {
        return data.readUInt16(at: 0x32)
    }
    
    /// The font records
    public func readFontAssociationTable() -> [FontAssociation] {
        var offset = 0x34
        let countMinusOne = data.readUInt16(at: offset)
        offset += 2
        let count = countMinusOne + 1
        var table: [FontAssociation] = []
        for _ in 0..<count {
            let size = data.readUInt16(at: offset)
            let styleFlags = data.readUInt16(at: offset + 2)
            let identifier = data.readUInt16(at: offset + 4)
            table.append(FontAssociation(size: size, style: TextStyle(flags: styleFlags), resourceIdentifier: identifier))
            offset += 6
        }
        return table
    }
    
}
