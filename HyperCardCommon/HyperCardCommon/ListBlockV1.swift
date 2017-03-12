//
//  CardList.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//




public class ListBlockV1: ListBlock {
    
    /* All the values are shifted but the card references are at the same offset */
    public override var pageCount: Int {
        return data.readUInt32(at: 0xC)
    }
    
    public override var pageSize: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public override var cardCount: Int {
        return data.readUInt32(at: 0x14)
    }
    
    public override var cardReferenceSize: Int {
        return data.readUInt16(at: 0x18)
    }
    
    public override var hashCountInCardReference: Int {
        return data.readUInt16(at: 0x1C)
    }
    
    public override var hashValueCount: Int {
        return data.readUInt16(at: 0x1E)
    }
    
    public override var checksum: Int {
        return data.readUInt32(at: 0x20)
    }
    
    public override var totalPageEntryCount: Int {
        return data.readUInt32(at: 0x24)
    }
    
}




