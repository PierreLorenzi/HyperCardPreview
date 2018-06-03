//
//  PictureResourceBlock.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


import AppKit


/// Apple PICT resource, with Apple internal format
public class PictureResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "PICT")!
    }
    
    public func readImage() -> NSImage {
        
        /* Copy the data */
        let slice = self.data.sharedData[self.data.offset..<self.data.offset + self.data.length]
        let data = Data(slice)
        
        /* Create an image */
        return NSImage(data: data)!
    }
    
}

