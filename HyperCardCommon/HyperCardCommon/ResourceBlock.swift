//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


open class ResourceBlock: DataBlock {
    
    public let identifier: Int
    public let name: HString
    
    open class var Name: NumericName {
        return NumericName(value: 0)
    }
    
    public required init(data: DataRange, identifier: Int, name: HString) {
        self.identifier = identifier
        self.name = name
        super.init(data: data)
    }
    
}
