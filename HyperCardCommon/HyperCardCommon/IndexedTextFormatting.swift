//
//  IndexedTextFormatting.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A reference to a style in the Style Block.
public struct IndexedTextFormatting {
    
    /// Offset of the style in the string content
    public let offset: Int
    
    /// ID of the style in the style table
    public let styleIdentifier: Int
}
