//
//  FontBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// The Font Block (FTBL), containing the names of the fonts used in the stack
public class FontBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "FTBL")!
    }
    
    public struct FontReference {
        public var identifier: Int
        public var name: HString
    }
    
    public var fontCount: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public var fontReferences: [FontReference] {
        let count = self.fontCount
        var offset = 0x18
        var fonts: [FontReference] = []
        for _ in 0..<count {
            let identifier = data.readUInt16(at: offset)
            let name = data.readString(at: offset + 0x2)
            fonts.append(FontReference(identifier: identifier, name: name))
            
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

