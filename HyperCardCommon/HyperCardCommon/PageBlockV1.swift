//
//  PageBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public class PageBlockV1: PageBlock {
    
    /* The values are shifted */
    public override var listIdentifier: Int {
        return data.readUInt32(at: 0xC)
    }
    public override var checksum: Int {
        return data.readUInt32(at: 0x10)
    }
    
}

