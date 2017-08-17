//
//  HypercardFile.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// An abstract class for a parsed data section in a file
/// <p>
/// Subclasses contain fields that are lazily read in the data section.
open class DataBlock {
    
    /// The pointed section of the file
    public let data: DataRange
    
    /// Main constructor
    public init(data: DataRange) {
        self.data = data
    }
    
}


