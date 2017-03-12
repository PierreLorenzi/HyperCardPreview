//
//  Image.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 13/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import AppKit


public struct Image {
    
    public var data: [UInt32]
    
    public let width: Int
    public let height: Int
    
    public let integerCountInRow: Int
    
    public init(width: Int, height: Int) {
        
        /* Compute the bounds */
        self.width = width
        self.height = height
        let integerCountInRow = upToMultiple(width, 32) / 32
        self.integerCountInRow = integerCountInRow
        
        /* Build the color data */
        let integerCount = integerCountInRow * height
        self.data = [UInt32](repeating: 0, count: integerCount)
        
    }
    
    public subscript(x: Int, y: Int) -> Bool {
        get {
            let integerIndexInRow = x / 32
            let indexInInteger = 31 - x & 31
            let integer = data[ y * integerCountInRow + integerIndexInRow ]
            let bit = (integer >> UInt32(indexInInteger)) & 1
            return bit == 1
        }
        set {
            /* Write the mask */
            let indexInInteger = 31 - x & 31
            let mask = UInt32(1 << indexInInteger)
            
            /* Locate the integer */
            let integerIndexInRow = x / 32
            let integerIndex =  y * integerCountInRow + integerIndexInRow
            
            /* Change the integer */
            let integer = data[integerIndex]
            let newInteger = (newValue) ? integer | mask : integer & ~mask
            data[integerIndex] = newInteger
        }
    }
    
}


struct RgbColor {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

let RgbWhite = RgbColor(a: 255, r: 255, g: 255, b: 255)
let RgbBlack = RgbColor(a: 255, r: 0, g: 0, b: 0)
let RgbTransparent = RgbColor(a: 0, r: 255, g: 255, b: 255)

let RgbColorSpace = CGColorSpaceCreateDeviceRGB()
let BitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
let BitmapInfoNotTransparent:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
let BitsPerComponent = 8
let BitsPerPixel = 32


public extension Image {
    
    public func convertToRgb() -> NSImage {
        
        var pixels = [RgbColor](repeating: RgbWhite, count: self.width*self.height)
        for x in 0..<self.width {
            for y in 0..<self.height {
                pixels[x + y*self.width] = self[x, y] ? RgbBlack : RgbWhite
            }
        }
        let data = NSMutableData(bytes: &pixels, length: pixels.count * MemoryLayout<RgbColor>.size)
        let providerRef = CGDataProvider(data: data)
        let cgimage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: BitsPerComponent,
            bitsPerPixel: BitsPerPixel,
            bytesPerRow: width * MemoryLayout<RgbColor>.size,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfoNotTransparent,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        
        return NSImage(cgImage: cgimage!, size: NSZeroSize)
    }
    
}




