//
//  RgbConversion.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Foundation


public class RgbConverter {

    /* The representations of the RGB colors in memory */
    private typealias RgbColor = UInt32
    private static let RgbWhite = RgbColor(0xFFFF_FFFF)
    private static let RgbBlack = RgbColor(0xFF00_0000)
    private static let RgbTransparent = RgbColor(0x0000_0000)
    
    /* Parameter to create CoreGraphics images */
    private static let RgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private static let BitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    private static let BitmapInfoNotTransparent:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
    private static let BitsPerComponent = 8
    private static let BitsPerPixel = 32
    
    /* Two RGB colors together, so we can copy two pixels at a time */
    private typealias RgbColor2 = UInt64
    private static let RgbWhiteWhite: RgbColor2 = 0xFFFF_FFFF_FFFF_FFFF
    private static let RgbBlackBlack: RgbColor2 = 0xFF00_0000_FF00_0000
    private static let RgbBlackWhite: RgbColor2 = 0xFFFF_FFFF_FF00_0000
    private static let RgbWhiteBlack: RgbColor2 = 0xFF00_0000_FFFF_FFFF
    private static let rgbColor2Table: [RgbColor2] = [RgbWhiteWhite, RgbWhiteBlack, RgbBlackWhite, RgbBlackBlack]
    
    public static func convertImage(_ image: Image) -> CGImage {
        
        /* Allocate a buffer for the image */
        let data = createRgbData(width: image.width, height: image.height)
        
        /* Fill the pixel colors */
        fillRgbData(data, withImage: image)
        
        /* Build the image */
        return createImage(owningRgbData: data, width: image.width, height: image.height)
    }
    
    public static func fillRgbData(_ rawBuffer: UnsafeMutableRawPointer, withImage image: Image) {
        
        /* Read the buffer as RgbColor2, so we can write two pixels at a time */
        let buffer = rawBuffer.assumingMemoryBound(to: RgbColor2.self)
        
        var offset = 0
        var integerIndex = 0
        
        for _ in 0..<image.height {
            for integerIndexInRow in 0..<image.integerCountInRow {
                
                /* Get 32 pixels */
                let integer = Int(image.data[integerIndex])
                integerIndex += 1
                
                /* Do no not copy pixels after the end of the image */
                let bitCount = min(32, image.width - integerIndexInRow * 32)
                
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
    
    public static func fillRgbDataWithBlackPixels(_ rawBuffer: UnsafeMutableRawPointer, withImage image: Image) {
        
        /* Read the buffer as RgbColor2, so we can write two pixels at a time */
        let buffer = rawBuffer.assumingMemoryBound(to: RgbColor.self)
        
        var offset = 0
        var integerIndex = 0
        
        for _ in 0..<image.height {
            for integerIndexInRow in 0..<image.integerCountInRow {
                
                /* Get 32 pixels */
                let integer = Int(image.data[integerIndex])
                integerIndex += 1
                
                /* Do no not copy pixels after the end of the image */
                let bitCount = min(32, image.width - integerIndexInRow * 32)
                
                /* Copy the pixels */
                var i = bitCount - 1
                while i >= 0 {
                    let pixelValue = (integer >> i) & 1
                    if pixelValue == 1 {
                        buffer[offset] = RgbBlack
                    }
                    offset += 1
                    i -= 1
                }
            }
        }
    }
    
    public static func createRgbData(width: Int, height: Int) -> UnsafeMutableRawPointer {
        
        let length = width * height * MemoryLayout<RgbColor>.size
        return UnsafeMutableRawPointer.allocate(bytes: length, alignedTo: 0)
    }
    
    public static func createContext(forRgbData data: UnsafeMutableRawPointer, width: Int, height: Int) -> CGContext {
        
        return CGContext(data: data,
                         width: width,
                         height: height,
                         bitsPerComponent: BitsPerComponent,
                         bytesPerRow: width * MemoryLayout<RgbColor>.size,
                         space: RgbColorSpace,
                         bitmapInfo: BitmapInfo.rawValue)!
    }
    
    public static func createImage(owningRgbData data: UnsafeMutableRawPointer, width: Int, height: Int) -> CGImage {
        
        let length = width * height * MemoryLayout<RgbColor>.size
        let dataProvider = CGDataProvider(dataInfo: nil, data: data, size: length, releaseData: {
            (_, data: UnsafeRawPointer, length: Int) in
            data.deallocate(bytes: length, alignedTo: 0)
        })!
        
        let cgimage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: BitsPerComponent,
            bitsPerPixel: BitsPerPixel,
            bytesPerRow: width * MemoryLayout<RgbColor>.size,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)!
        
        return cgimage
    }
    
    /// Converts the HyperCard image to a Cocoa image
    public static func convertMaskedImage(_ image: MaskedImage) -> CGImage {
        
        var pixels = [RgbColor](repeating: RgbWhite, count: image.width*image.height)
        for x in 0..<image.width {
            for y in 0..<image.height {
                pixels[x + y*image.width] = convertToRgb(image[x, y])
            }
        }
        let data = NSMutableData(bytes: &pixels, length: pixels.count * MemoryLayout<RgbColor>.size)
        let providerRef = CGDataProvider(data: data)
        let cgimage = CGImage(
            width: image.width,
            height: image.height,
            bitsPerComponent: BitsPerComponent,
            bitsPerPixel: BitsPerPixel,
            bytesPerRow: image.width * MemoryLayout<RgbColor>.size,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        
        return cgimage!
    }
    
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
    
}

