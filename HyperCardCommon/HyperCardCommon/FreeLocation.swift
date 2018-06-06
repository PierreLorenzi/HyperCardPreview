//
//  FreeLocation.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Record of a free block in a stack file
public struct FreeLocation {
    
    /// Offset in the file
    public var offset: Int
    
    /// Length
    public var size: Int
}
