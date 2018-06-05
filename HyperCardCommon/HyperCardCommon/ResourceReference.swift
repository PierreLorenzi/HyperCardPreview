//
//  ResourceReference.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A resource record in the map
public struct ResourceReference {
    
    /// Type of the resource
    public var type: NumericName
    
    /// ID of the resource
    public var identifier: Int
    
    /// Name of the resource
    public var name: HString
    
    /// Offset of the resource in the data section of the resource fork
    public var dataOffset: Int
}
