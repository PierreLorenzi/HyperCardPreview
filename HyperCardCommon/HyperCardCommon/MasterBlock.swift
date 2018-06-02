//
//  Master.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// The master block (MAST), containing the locations of the other blocks
public class MasterBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "MAST")!
    }
    
    /// A record of a data block
    public struct Entry {
        
        /// Last byte of the identifier of the data block (it can be ambiguous, the whole
        /// identifier must be checked at the block)
        public let identifierLastByte: Int
        
        /// Offset of the data block in the stack file
        public let offset: Int
    }
    
    /// Records of the data blocks in the stack file
    public func readEntries() -> [Entry] {
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
