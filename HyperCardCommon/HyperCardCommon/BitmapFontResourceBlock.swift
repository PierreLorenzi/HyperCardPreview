//
//  FontResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public class BitmapFontResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "NFNT")!
    }
    
    
    public var containsImageHeightTable: Bool {
        return data.readFlag(at: 0, bitOffset: 0)
    }
    
    public var containsGlyphWidthTable: Bool {
        return data.readFlag(at: 0, bitOffset: 1)
    }
    
    public var firstCharacterCode: Int {
        return data.readUInt16(at: 0x2)
    }
    
    public var lastCharacterCode: Int {
        return data.readUInt16(at: 0x4)
    }
    
    public var maximumWidth: Int {
        return data.readUInt16(at: 0x6)
    }
    
    public var maximumKerning: Int {
        return data.readSInt16(at: 0x8)
    }
    
    public var negatedDescentValue: Int {
        return data.readUInt16(at: 0xA)
    }
    
    public var fontRectangleWidth: Int {
        return data.readUInt16(at: 0xC)
    }
    
    public var fontRectangleHeight: Int {
        return data.readUInt16(at: 0xE)
    }
    
    public var widthOffsetTableOffset: Int {
        return data.readUInt16(at: 0x10)
    }
    
    public var maximumAscent: Int {
        return data.readUInt16(at: 0x12)
    }
    
    public var maximumDescent: Int {
        return data.readUInt16(at: 0x14)
    }
    
    public var leading: Int {
        return data.readUInt16(at: 0x16)
    }
    
    public var bitImageRowWidth: Int {
        return data.readUInt16(at: 0x18)
    }
    
    public var bitImage: Image {
        return Image(data: data.sharedData, offset: data.offset + 0x1A, width: self.bitImageRowWidth*16, height: self.fontRectangleHeight)
    }
    
    private var bitImageSize: Int {
        return self.bitImageRowWidth * 2 *  self.fontRectangleHeight
    }
    
    private var bitmapLocationTableSize: Int {
        return (self.characterCount + 1) * 2
    }
    
    private var characterCount: Int {
        return self.lastCharacterCode - self.firstCharacterCode + 2
    }
    
    public var bitmapLocationTable: [Int] {
        let tableCount = self.characterCount + 1
        var locations = [Int](repeating: 0, count: tableCount)
        let startOffset = 0x1A + self.bitImageSize
        for i in 0..<tableCount {
            let value = data.readUInt16(at: startOffset + 2 * i)
            locations[i] = value
        }
        return locations
    }
    
    public var offsetTable: [Int] {
        let count = self.characterCount
        var widths = [Int](repeating: 0, count: count)
        let startOffset = 0x1A + self.bitImageSize + self.bitmapLocationTableSize
        for i in 0..<count {
            let value = data.readSInt16(at: startOffset + 2 * i)
            if value == -1 {
                continue
            }
            widths[i] = value >> 8
        }
        return widths
    }
    
    public var widthTable: [Int] {
        let count = self.characterCount
        var widths = [Int](repeating: 0, count: count)
        let startOffset = 0x1A + self.bitImageSize + self.bitmapLocationTableSize
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

