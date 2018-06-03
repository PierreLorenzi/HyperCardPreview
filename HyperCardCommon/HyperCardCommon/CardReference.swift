//
//  CardReference.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Record of a card in a page
public struct CardReference {
    
    /// Identifier of the card
    public var identifier: Int
    
    /// Is card marked
    public var marked: Bool
    
    /// Has the card text content in the fields
    public var hasTextContent: Bool
    
    /// Is the card at the beginning of a background
    public var isStartOfBackground: Bool
    
    /// Has the card a name
    public var hasName: Bool
    
    /// The search hash of the card
    public var searchHash: SearchHash
}
