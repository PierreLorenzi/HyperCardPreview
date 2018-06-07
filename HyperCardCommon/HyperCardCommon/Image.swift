//
//  Image.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 13/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import AppKit


/// A 1-bit image without mask
/// <p>
/// We don't use a Cocoa image because there are a lot of specific processes in 1-bit images.
public struct Image: Equatable {
    
    /// The underlying integer type used to store the pixel data. Can be UInt32 or UInt64.
    public typealias Integer = UInt64
    
    /// The bits, stored in 32-bit integers. A row always starts at the beginning of an integer,
    /// so there may be unused bits at the end of every row for 32-bit alignment.
    public var data: [Image.Integer]
    
    /// Width of the image, in pixels
    public let width: Int
    
    /// Height of the image, in pixels
    public let height: Int
    
    /// Number of 32-bit integers that make up a row in the data
    public let integerCountInRow: Int
    
    /// Main constructor. Build a blank image.
    public init(width: Int, height: Int) {
        
        /* Compute the bounds */
        self.width = width
        self.height = height
        let integerCountInRow = upToMultiple(width, Image.Integer.bitWidth) / Image.Integer.bitWidth
        self.integerCountInRow = integerCountInRow
        
        /* Build the color data */
        let integerCount = integerCountInRow * height
        self.data = [Image.Integer](repeating: 0, count: integerCount)
        
    }
    
    /// Returns whether or not the pixel at (x,y) is activated.
    /// <p>
    /// x is counted from the left, y from the top.
    public subscript(x: Int, y: Int) -> Bool {
        get {
            let integerIndexInRow = x / Image.Integer.bitWidth
            let indexInInteger = Image.Integer.bitWidth - 1 - x % Image.Integer.bitWidth
            let integer = data[ y * integerCountInRow + integerIndexInRow ]
            let bit = (integer >> indexInInteger) & 1
            return bit == 1
        }
        set {
            /* Write the mask */
            let indexInInteger = Image.Integer.bitWidth - 1 - x % Image.Integer.bitWidth
            let mask = (Image.Integer(1) << indexInInteger)
            
            /* Locate the integer */
            let integerIndexInRow = x / Image.Integer.bitWidth
            let integerIndex =  y * integerCountInRow + integerIndexInRow
            
            /* Change the integer */
            let integer = data[integerIndex]
            let newInteger = (newValue) ? integer | mask : integer & ~mask
            data[integerIndex] = newInteger
        }
    }
    
    public static func ==(image1: Image, image2: Image) -> Bool {
        
        /* Check size */
        guard image1.width == image2.width && image1.height == image2.height else {
            return false
        }
        
        /* Check the complete integers */
        var integerIndex = 0
        if image1.integerCountInRow > 1 {
            for _ in 0..<image1.height {
                for _ in 0..<(image1.integerCountInRow - 1) {
                    guard image1.data[integerIndex] == image2.data[integerIndex] else {
                        return false
                    }
                    integerIndex += 1
                }
                integerIndex += 1
            }
        }
        
        /* Check the last integers of the rows */
        let mask = Image.Integer.max << (image1.integerCountInRow * Image.Integer.bitWidth - image1.width)
        integerIndex = image1.integerCountInRow - 1
        for _ in 0..<image1.height {
            guard image1.data[integerIndex] & mask == image2.data[integerIndex] & mask else {
                return false
            }
            integerIndex += image1.integerCountInRow
        }
        
        return true
    }
    
}




