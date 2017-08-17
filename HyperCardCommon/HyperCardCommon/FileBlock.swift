//
//  HyperCardFileBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// An abstract class for a data block of a HyperCard stack.
/// <p>
/// Internally, stacks are composed of a sequence of data blocks. Data blocks can be of
/// several types: STAK, MAST, LIST and so on.
open class HyperCardFileBlock: DataBlock {
    
    /// The identifier of the type of the data block
    class var Name: NumericName {
        return NumericName(value: 0)
    }
    
    /// The identifier of the data block
    public var identifier: Int {
        return data.readSInt32(at: 0x8)
    }
    
}
