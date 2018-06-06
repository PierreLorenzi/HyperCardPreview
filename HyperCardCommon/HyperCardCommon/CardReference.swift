//
//  CardReference.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Record of a card block in a page block
public struct CardReference {
    
    /// Identifier of the card
    public var identifier: Int
    
    /// Is card marked
    public var marked: Bool
    
    /// If the card has some text content in its fields
    public var hasTextContent: Bool
    
    /// Is the card at the beginning of a background
    public var isStartOfBackground: Bool
    
    /// Has the card a name
    public var hasName: Bool
    
    /// The search hash of the card
    public var searchHash: SearchHash
}
