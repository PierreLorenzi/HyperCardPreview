//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A parsed block of a resource in a resource fork
open class ResourceBlock: DataBlock {
    
    /// ID of the resource
    /// <p>
    /// This parameter is present in the resource map
    public let identifier: Int
    
    /// Name of the resource
    /// <p>
    /// This parameter is present in the resource map
    public let name: HString
    
    /// Type of the resoure
    open class var Name: NumericName {
        return NumericName(value: 0)
    }
    
    /// Main constructor
    public required init(data: DataRange, identifier: Int, name: HString) {
        self.identifier = identifier
        self.name = name
        super.init(data: data)
    }
    
}
