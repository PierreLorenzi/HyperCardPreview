//
//  CardList.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//




/// Subclass for V1 stacks
public class ListBlockV1: ListBlock {
    
    /* All the values are shifted but the card references are at the same offset */
    public override func readPageCount() -> Int {
        return data.readUInt32(at: 0xC)
    }
    
    public override func readPageSize() -> Int {
        return data.readUInt32(at: 0x10)
    }
    
    public override func readCardCount() -> Int {
        return data.readUInt32(at: 0x14)
    }
    
    public override func readCardReferenceSize() -> Int {
        return data.readUInt16(at: 0x18)
    }
    
    public override func readHashCountInCardReference() -> Int {
        return data.readUInt16(at: 0x1C)
    }
    
    public override func readHashValueCount() -> Int {
        return data.readUInt16(at: 0x1E)
    }
    
    public override func readChecksum() -> Int {
        return data.readUInt32(at: 0x20)
    }
    
    public override func readTotalPageEntryCount() -> Int {
        return data.readUInt32(at: 0x24)
    }
    
}




