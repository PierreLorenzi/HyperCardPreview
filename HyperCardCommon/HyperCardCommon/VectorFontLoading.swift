//
//  VectorFontLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension VectorFont {
    
    public init(loadFromData dataRange: DataRange) {
        
        /* Copy the data */
        let slice = dataRange.sharedData[dataRange.offset..<dataRange.offset + dataRange.length]
        let data = Data(slice)
        
        /* Build a data provider */
        let nsdata = NSData(data: data)
        let dataProvider = CGDataProvider(data: nsdata)
        
        let cgfont = CGFont(dataProvider!)!
        self.init(cgfont: cgfont)
    }
    
}
