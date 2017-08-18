//
//  TextStyle.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// The Style Block contain the text styles used in the stack.
public class StyleBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "STBL")!
    }
    
    /// A record of a text style
    public struct Style {
        
        /// The ID of the style
        public var number: Int
        
        /// The number of times this style is used in the stack
        public var runCount: Int
        
        /// The text attribute
        public var textAttribute: TextFormatting
    }
    
    /// Number of text styles
    public var styleCount: Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// Style ID to use for next style
    public var nextAvailableStyleNumber: Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// The text styles
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

