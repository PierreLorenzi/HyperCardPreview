//
//  FontBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// The font name table.
/// <p>
/// Since fonts IDs were not consistent across the installations, HyperCard stores a table of the names of the fonts used in the stack. This block appears only once in a file.
public class FontBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "FTBL")!
    }
    
    /// Number of font names
    public func readFontCount() -> Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// The font names
    public func readFontReferences() -> [FontNameReference] {
        let count = self.readFontCount()
        var offset = 0x18
        var fonts: [FontNameReference] = []
        for _ in 0..<count {
            let identifier = data.readUInt16(at: offset)
            let name = data.readString(at: offset + 0x2)
            fonts.append(FontNameReference(identifier: identifier, name: name))
            
            /* Advance after the name, 16-bit aligned */
            offset += 2
            while data.readUInt8(at: offset) != 0 {
                offset += 1
            }
            offset += 1
            if offset & 1 != 0 {
                offset += 1
            }
        }
        return fonts
    }
}

