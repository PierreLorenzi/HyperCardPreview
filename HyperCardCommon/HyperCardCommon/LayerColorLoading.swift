//
//  LayerColorLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension LayerColor {
    
    /// Loads AddColor declarations from the data of a HCcd or HCbg resource
    init(loadFromData data: DataRange) {
        
        let reader = ColorResourceReader(data: data)
        let elements = reader.readElements()
        self.init(elements: elements)
    }
    
}
