//
//  PageBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




/// Subclass for V1 stacks
public class PageBlockV1: PageBlock {
    
    /* The values are shifted */
    public override func readListIdentifier() -> Int {
        return data.readUInt32(at: 0xC)
    }
    public override func readChecksum() -> Int {
        return data.readUInt32(at: 0x10)
    }
    
}

