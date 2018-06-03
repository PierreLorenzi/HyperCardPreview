//
//  BitmapBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit

/// Subclass for V1 stacks
public class BitmapBlockV1: BitmapBlock {
    
    /* All the values are shifted */
    
    public override func readCardRectangle() -> Rectangle {
        return data.readRectangle(at: 0x14)
    }
    
    public override func readMaskRectangle() -> Rectangle {
        return data.readRectangle(at: 0x1C)
    }
    
    public override func readImageRectangle() -> Rectangle {
        return data.readRectangle(at: 0x24)
    }
    
    public override func readMaskLength() -> Int {
        return data.readUInt32(at: 0x34)
    }
    
    public override func readImageLength() -> Int {
        return data.readUInt32(at: 0x38)
    }
    
    public override func readDataOffset() -> Int {
        return 0x3C
    }
    
}
