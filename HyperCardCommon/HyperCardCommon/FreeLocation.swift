//
//  FreeLocation.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Record of a free block in a stack file
public struct FreeLocation {
    public var offset: Int
    public var size: Int
}
