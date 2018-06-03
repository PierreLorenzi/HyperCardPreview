//
//  MasterRecord.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A record of a data block
public struct MasterRecord {
    
    /// Last byte of the identifier of the data block (it can be ambiguous, the whole
    /// identifier must be checked at the block)
    public let identifierLastByte: Int
    
    /// Offset of the data block in the stack file
    public let offset: Int
}
