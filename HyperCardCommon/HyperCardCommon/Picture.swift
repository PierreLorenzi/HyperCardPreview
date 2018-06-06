//
//  Picture.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A colored picture
public struct Picture {
    
    /// The NSImage used to represent the picture. NSImage is used because it is still
    /// able to read the old Apple-centric PICT image format.
    public var nsimage: NSImage
}
