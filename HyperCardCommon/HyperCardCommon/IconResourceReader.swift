//
//  IconResourceReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Parsed icon resource
public struct IconResourceReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// Image of the icon
    public func readImage() -> Image {
        
        /* Build an image with the data of the row */
        return Image(data: self.data.sharedData, offset: self.data.offset, width: Icon.size, height: Icon.size)
    }
    
}
