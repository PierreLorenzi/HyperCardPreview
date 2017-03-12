//
//  BitmapBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit

public class BitmapBlockV1: BitmapBlock {
    
    /* All the values are shifted */
    
    public override var cardRectangle: Rectangle {
        return data.readRectangle(at: 0x14)
    }
    
    public override var maskRectangle: Rectangle {
        return data.readRectangle(at: 0x1C)
    }
    
    public override var imageRectangle: Rectangle {
        return data.readRectangle(at: 0x24)
    }
    
    public override var maskLength: Int {
        return data.readUInt32(at: 0x34)
    }
    
    public override var imageLength: Int {
        return data.readUInt32(at: 0x38)
    }
    
    public override var dataOffset: Int {
        return 0x3C
    }
    
}
