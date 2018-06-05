//
//  VectorFontResourceReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Parsed vector font resource
public struct VectorFontResourceReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// The resource contains a vector font file, that can be read with Core Graphics
    public func readCGFont() -> CGFont {
        
        /* Copy the data */
        let slice = self.data.sharedData[self.data.offset..<self.data.offset + self.data.length]
        let data = Data(slice)
        
        /* Build a data provider */
        let nsdata = NSData(data: data)
        let dataProvider = CGDataProvider(data: nsdata)
        
        return CGFont(dataProvider!)!
    }
    
}
