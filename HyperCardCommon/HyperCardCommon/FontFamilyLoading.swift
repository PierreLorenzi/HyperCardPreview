//
//  FileFontFamily.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


extension FontFamily: ResourceContent {
    
    /// Loads a font family from the data of a FOND resource
    public init(loadFromData data: DataRange) {
                
        /* Get the references from the resource */
        let associations = FontFamily.readFontAssociationTable(in: data)
        
        /* Build the fonts */
        let bitmapFonts: [FontFamily.FamilyBitmapFont] = associations.filter({ $0.size != 0 }).map({ FontFamily.FamilyBitmapFont(size: $0.size, style: $0.style, resourceIdentifier: $0.resourceIdentifier) })
        let vectorFonts: [FontFamily.FamilyVectorFont] = associations.filter({ $0.size == 0 }).map({ FontFamily.FamilyVectorFont(style: $0.style, resourceIdentifier: $0.resourceIdentifier) })
        
        /* Build the family */
        self.init()
        self.bitmapFonts = bitmapFonts
        self.vectorFonts = vectorFonts
        
        let useIntegerExtraWidth = data.readFlag(at: 0, bitOffset: 13)
        self.styleProperties = (useIntegerExtraWidth ? nil : FontFamily.readStyleProperties(in: data))
        
    }
    
    private struct FontAssociation {
        
        var size: Int
        var style: TextStyle
        var resourceIdentifier: Int
    }
    
    private static func readFontAssociationTable(in data: DataRange) -> [FontAssociation] {
        
        var offset = 0x34
        
        let countMinusOne = data.readUInt16(at: offset)
        offset += 2
        let count = countMinusOne + 1
        
        var table: [FontAssociation] = []
        
        for _ in 0..<count {
            
            let size = data.readUInt16(at: offset)
            let styleFlags = data.readUInt16(at: offset + 2)
            let identifier = data.readUInt16(at: offset + 4)
            
            let association = FontAssociation(size: size, style: TextStyle(flags: styleFlags), resourceIdentifier: identifier)
            table.append(association)
            
            offset += 6
        }
        
        return table
    }
    
    /// Each value indicates the extra width, in pixels, that would be added to the glyphs of a 1-point font in this font family after a stylistic variation has been applied
    private static func readStyleProperties(in data: DataRange) -> FontStyleProperties {
        
        let plainExtraWidth = data.readFraction(at: 0x1C)
        let boldExtraWidth = data.readFraction(at: 0x1E)
        let italicExtraWidth = data.readFraction(at: 0x20)
        let underlineExtraWidth = data.readFraction(at: 0x22)
        let outlineExtraWidth = data.readFraction(at: 0x24)
        let shadowExtraWidth = data.readFraction(at: 0x26)
        let condensedExtraWidth = data.readFraction(at: 0x28)
        let extendedExtraWidth = data.readFraction(at: 0x2A)
        
        return FontStyleProperties(plainExtraWidth: plainExtraWidth, boldExtraWidth: boldExtraWidth, italicExtraWidth: italicExtraWidth, underlineExtraWidth: underlineExtraWidth, outlineExtraWidth: outlineExtraWidth, shadowExtraWidth: shadowExtraWidth, condensedExtraWidth: condensedExtraWidth, extendedExtraWidth: extendedExtraWidth)
    }
    
}

private extension DataRange {
    
    func readFraction(at offset: Int) -> Double {
        let bits = self.readUInt16(at: offset)
        
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
}
