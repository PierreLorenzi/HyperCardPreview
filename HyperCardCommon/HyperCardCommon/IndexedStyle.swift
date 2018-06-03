//
//  IndexedStyle.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A record of a text style
public struct IndexedStyle {
    
    /// The ID of the style
    public var number: Int
    
    /// The number of times this style is used in the stack
    public var runCount: Int
    
    /// The text attribute
    public var textAttribute: TextFormatting
}
