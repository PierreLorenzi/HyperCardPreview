//
//  HyperCardFileBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


open class HyperCardFileBlock: DataBlock {
    
    class var Name: NumericName {
        return NumericName(value: 0)
    }
    
    public var identifier: Int {
        return data.readSInt32(at: 0x8)
    }
    
}
