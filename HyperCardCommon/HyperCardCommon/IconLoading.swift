//
//  IconLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension Icon {
    
    /// Loads an icon from the data of a ICON resource
    public init(loadFromData data: DataRange) {
        
        self.image = Image(data: data.sharedData, offset: data.offset, width: Icon.size, height: Icon.size)
    }
    
}
