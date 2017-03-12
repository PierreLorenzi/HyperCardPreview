//
//  BackgroundBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class BackgroundBlock: LayerBlock {
    
    override public class var Name: NumericName {
        return NumericName(string: "BKGD")!
    }
    
    public required convenience init(data: DataRange) {
        self.init(data: data, partOffset: 0x32)
    }
    
    /* Initializer for background v1 */
    override init(data: DataRange, partOffset: Int) {
        super.init(data: data, partOffset: partOffset)
    }
    
    public var cardCount: Int {
        return data.readUInt32(at: 0x18)
    }
    
    public var nextBackgroundIdentifier: Int {
        return data.readSInt32(at: 0x1C)
    }
    
    public var previousBackgroundIdentifier: Int {
        return data.readSInt32(at: 0x20)
    }
    
}
