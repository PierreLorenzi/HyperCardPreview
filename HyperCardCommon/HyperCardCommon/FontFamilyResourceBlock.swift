//
//  FontFamilyResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//



public class FontFamilyResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "FOND")!
    }
    
    public struct StyleProperties {
        var plainExtraWidth: Int
        var boldExtraWidth: Int
        var italicExtraWidth: Int
        var underlineExtraWidth: Int
        var outlineExtraWidth: Int
        var shadowExtraWidth: Int
        var condensedExtraWidth: Int
        var extendedExtraWidth: Int
    }
    
    public struct FontAssociation {
        public let size: Int
        public let style: TextStyle
        public let resourceIdentifier: Int
    }
    
    private func readFraction(at offset: Int) -> Double {
        let number = data.readSInt16(at: offset)
        return Double(number) / Double(1 << 12)
    }
    
    public var containsGlyphWidthTable: Bool {
        return data.readFlag(at: 0, bitOffset: 1)
    }
    
    public var isFixedWidth: Bool {
        return data.readFlag(at: 0, bitOffset: 15)
    }
    
    public var fontIdentifier: Int {
        return data.readUInt16(at: 0x2)
    }
    
    public var firstCharacterCode: Int {
        return data.readUInt16(at: 0x4)
    }
    
    public var lastCharacterCode: Int {
        return data.readUInt16(at: 0x6)
    }
    
    public var maximumAscent: Double {
        return self.readFraction(at: 0x8)
    }
    
    public var maximumDescent: Double {
        return self.readFraction(at: 0xA)
    }
    
    public var maximumLeading: Double {
        return self.readFraction(at: 0xC)
    }
    
    public var maximumGlyphWidth: Double {
        return self.readFraction(at: 0xE)
    }
    
    public var glyphWidthTableOffset: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public var kerningTableOffset: Int {
        return data.readUInt32(at: 0x14)
    }
    
    public var styleMappingTableOffset: Int {
        return data.readUInt32(at: 0x18)
    }
    
    public var styleProperties: StyleProperties {
        
        let plainExtraWidth = data.readUInt16(at: 0x1C)
        let boldExtraWidth = data.readUInt16(at: 0x1E)
        let italicExtraWidth = data.readUInt16(at: 0x20)
        let underlineExtraWidth = data.readUInt16(at: 0x22)
        let outlineExtraWidth = data.readUInt16(at: 0x24)
        let shadowExtraWidth = data.readUInt16(at: 0x26)
        let condensedExtraWidth = data.readUInt16(at: 0x28)
        let extendedExtraWidth = data.readUInt16(at: 0x2A)
        
        return StyleProperties(plainExtraWidth: plainExtraWidth, boldExtraWidth: boldExtraWidth, italicExtraWidth: italicExtraWidth, underlineExtraWidth: underlineExtraWidth, outlineExtraWidth: outlineExtraWidth, shadowExtraWidth: shadowExtraWidth, condensedExtraWidth: condensedExtraWidth, extendedExtraWidth: extendedExtraWidth)
    }
    
    public var version: Int {
        return data.readUInt16(at: 0x32)
    }
    
    public var fontAssociationTable: [FontAssociation] {
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
