//
//  PageReference.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Reference of a page block in the list block
public struct PageReference {
    
    /// Identifier of the PAGE block
    public var identifier: Int
    
    /// Number of cards listed in the PAGE block
    public var cardCount: Int
}
