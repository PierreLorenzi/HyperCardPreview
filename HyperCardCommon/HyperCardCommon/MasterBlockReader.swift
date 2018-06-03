//
//  MasterBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// The master block (MAST), containing the locations of the other blocks
public struct MasterBlockReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// Records of the data blocks in the stack file
    public func readRecords() -> [MasterRecord] {
        var entries: [MasterRecord] = []
        let blockLength = self.data.length
        for offset in stride(from: 0x20, to: blockLength, by: 4) {
            let entryData = data.readUInt32(at: offset)
            guard entryData != 0 else {
                continue
            }
            entries.append(MasterRecord(identifierLastByte: entryData & 0xFF, offset: (entryData >> 8) * 32))
        }
        return entries
    }
    
}
