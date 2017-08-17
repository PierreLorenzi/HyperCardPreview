//
//  TextStyle.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// The Style Block (STBL), containing the text styles used in the stack.
public class StyleBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "STBL")!
    }
    
    public struct Style {
        public var number: Int
        public var runCount: Int
        public var textAttribute: TextFormatting
    }
    
    public var styleCount: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public var nextAvailableStyleNumber: Int {
        return data.readUInt32(at: 0x14)
    }
    
    public var styles: [Style] {
        let count = self.styleCount
        var offset = 0x18
        var styles: [Style] = []
        for _ in 0..<count {
            let number = data.readUInt32(at: offset)
            let runCount = data.readUInt16(at: offset + 0x6)
            let fontFamilyIdentifierValue = data.readSInt16(at: offset + 0xC)
            let styleFlagsValue = data.readSInt16(at: offset + 0xE)
            let sizeValue = data.readSInt16(at: offset + 0x10)
            let fontFamilyIdentifier: Int? = (fontFamilyIdentifierValue == -1) ? nil : fontFamilyIdentifierValue
            let style: TextStyle? = (styleFlagsValue == -1) ? nil : TextStyle(flags: styleFlagsValue >> 8)
            let size: Int? = (sizeValue == -1) ? nil : sizeValue
            let attribute = TextFormatting(fontFamilyIdentifier: fontFamilyIdentifier, size: size, style: style)
            styles.append(Style(number: number, runCount: runCount, textAttribute: attribute))
            offset += 0x18
        }
        return styles
    }
    
}

