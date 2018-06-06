//
//  StyleBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Reads inside a Style Block (STLB) data, which contains the text styles used in
/// the rich texts of the stack.
public struct StyleBlockReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// Identifier
    public func readIdentifier() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    public func readStyleCount() -> Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// Style ID to use for next style
    public func readNextAvailableStyleNumber() -> Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// The text styles
    public func readStyles() -> [IndexedStyle] {
        let count = self.readStyleCount()
        var offset = 0x18
        var styles: [IndexedStyle] = []
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
            styles.append(IndexedStyle(number: number, runCount: runCount, textAttribute: attribute))
            offset += 0x18
        }
        return styles
    }
    
}
