//
//  PictureResourceReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Apple PICT resource, with Apple internal format
public struct PictureResourceReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    public func readImage() -> NSImage {
        
        /* Copy the data */
        let slice = self.data.sharedData[self.data.offset..<self.data.offset + self.data.length]
        let data = Data(slice)
        
        /* Create an image */
        return NSImage(data: data)!
    }
    
}
