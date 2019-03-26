//
//  PictureLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension Picture {
    
    /// Loads a picture from the data of a PICT resource
    init(loadFromData dataRange: DataRange) {
        
        /* Copy the data */
        let slice = dataRange.sharedData[dataRange.offset..<dataRange.offset + dataRange.length]
        let data = Data(slice)
        
        /* Create an image */
        let nsimage = NSImage(data: data)!
        self.init(nsimage: nsimage)
    }
    
}
