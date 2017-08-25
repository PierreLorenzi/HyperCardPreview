//
//  RgbConversion.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Foundation



/* The representations of the RGB colors in memory */
private typealias RgbColor = UInt32
private let RgbWhite = RgbColor(0xFFFF_FFFF)
private let RgbBlack = RgbColor(0xFF00_0000)
private let RgbTransparent = RgbColor(0x0000_0000)

/* Parameter to create CoreGraphics images */
private let RgbColorSpace = CGColorSpaceCreateDeviceRGB()
private let BitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
private let BitmapInfoNotTransparent:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
private let BitsPerComponent = 8
private let BitsPerPixel = 32

/* Two RGB colors together, so we can copy two pixels at a time */
private typealias RgbColor2 = UInt64
private let RgbWhiteWhite: RgbColor2 = 0xFFFF_FFFF_FFFF_FFFF
private let RgbBlackBlack: RgbColor2 = 0xFF00_0000_FF00_0000
private let RgbBlackWhite: RgbColor2 = 0xFFFF_FFFF_FF00_0000
private let RgbWhiteBlack: RgbColor2 = 0xFF00_0000_FFFF_FFFF
private let rgbColor2Table: [RgbColor2] = [RgbWhiteWhite, RgbWhiteBlack, RgbBlackWhite, RgbBlackBlack]


public extension Image {
    
    /// Converts a HyperCard image to a Cocoa image
    public func convertToRgb() -> NSImage {
        
        /* Convert the 1-bit image to RGB */
        let bufferLength = self.width * self.height * MemoryLayout<RgbColor>.size
        let data = NSMutableData(length: bufferLength)!
        let buffer = data.mutableBytes.assumingMemoryBound(to: RgbColor2.self)
        self.fillBuffer(buffer)
        
        /* Build a CoreGraphics image */
        let providerRef = CGDataProvider(data: data)
        let cgimage = CGImage(
            width: self.width,
            height: self.height,
            bitsPerComponent: BitsPerComponent,
            bitsPerPixel: BitsPerPixel,
            bytesPerRow: width * MemoryLayout<RgbColor>.size,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        
        return NSImage(cgImage: cgimage!, size: NSZeroSize)
    }
    
    private func fillBuffer(_ buffer: UnsafeMutablePointer<RgbColor2>) {
        
        var offset = 0
        var integerIndex = 0
        
        for _ in 0..<self.height {
            for integerIndexInRow in 0..<self.integerCountInRow {
                
                /* Get 32 pixels */
                let integer = Int(self.data[integerIndex])
                integerIndex += 1
                
                /* Do no not copy pixels after the end of the image */
                let bitCount = min(32, self.width - integerIndexInRow * 32)
                
                /* Copy the pixels two by two */
                var i = bitCount - 2
                while i >= 0 {
                    let twoPixelValue = (integer >> i) & 0b11
                    let twoPixelColor = rgbColor2Table[twoPixelValue]
                    buffer[offset] = twoPixelColor
                    offset += 1
                    i -= 2
                }
            }
        }
    }
    
}



public extension MaskedImage {
    
    private static func convertToRgb(_ color: MaskedImage.Color) -> RgbColor {
        switch color {
        case .white:
            return RgbWhite
        case .black:
            return RgbBlack
        case .transparent:
            return RgbTransparent
        }
    }
    
    /// Converts the HyperCard image to a Cocoa image
    public func convertToRgb() -> NSImage {
        
        var pixels = [RgbColor](repeating: RgbWhite, count: self.width*self.height)
        for x in 0..<self.width {
            for y in 0..<self.height {
                pixels[x + y*self.width] = MaskedImage.convertToRgb(self[x, y])
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
            bitmapInfo: BitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        
        return NSImage(cgImage: cgimage!, size: NSZeroSize)
    }
    
}


