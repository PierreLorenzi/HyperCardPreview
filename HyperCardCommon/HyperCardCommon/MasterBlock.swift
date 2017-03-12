//
//  Master.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public class MasterBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "MAST")!
    }
    
    public struct Entry {
        let identifierLastByte: Int
        let offset: Int
    }
    
    public var entries: [Entry] {
        var entries: [Entry] = []
        let blockLength = self.data.length
        for offset in stride(from: 0x20, to: blockLength, by: 4) {
            let entryData = data.readUInt32(at: offset)
            guard entryData != 0 else {
                continue
            }
            entries.append(Entry(identifierLastByte: entryData & 0xFF, offset: (entryData >> 8) * 32))
        }
        return entries
    }
    
}
