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
        return createImage(forRgbData: data, isOwner: true, width: image.width, height: image.height)
    }
    
    public static func fillRgbData(_ rawBuffer: UnsafeMutableRawPointer, withImage image: Image, rectangle possibleRectangle: Rectangle? = nil) {
        
        /* Read the buffer as RgbColor2, so we can write two pixels at a time */
        let buffer = rawBuffer.assumingMemoryBound(to: RgbColor2.self)
        
        /* Compute the rectangle to update. It must be at an even pixel number because we update two pixels at a time */
        let unevenRectangle = possibleRectangle ?? Rectangle(x: 0, y: 0, width: image.width, height: image.height)
        let rectangle = Rectangle(top: unevenRectangle.top, left: downToMultiple(unevenRectangle.left, 2), bottom: unevenRectangle.bottom, right: upToMultiple(unevenRectangle.right, 2))
        
        var offset = (rectangle.top * image.width + rectangle.left) / 2
        var integerIndex = rectangle.top * image.integerCountInRow + rectangle.left / Image.Integer.bitWidth
        
        /* Compute the bounds of the integers */
        let startInteger = rectangle.left / Image.Integer.bitWidth
        let endInteger = upToMultiple(rectangle.right, Image.Integer.bitWidth) / Image.Integer.bitWidth
        
        /* Compute horizontal increments between the end of one row and the start of the next */
        let offsetIncrement = (rectangle.left + image.width - rectangle.right) / 2
        let integerIndexIncrement = startInteger + image.integerCountInRow - endInteger
        
        for _ in rectangle.top..<rectangle.bottom {
            for integerIndexInRow in startInteger..<endInteger {
                
                /* Get 32 pixels */
                let integer = image.data[integerIndex]
                integerIndex += 1
                
                /* Do no not copy pixels after the end of the image */
                let startBit = Image.Integer.bitWidth - max(0, rectangle.left - integerIndexInRow * Image.Integer.bitWidth)
                let endBit = Image.Integer.bitWidth - min(Image.Integer.bitWidth, rectangle.right - integerIndexInRow * Image.Integer.bitWidth)
                
                /* Copy the pixels two by two */
                var i = startBit - 2
                while i >= endBit {
                    let twoPixelValue = Int(truncatingIfNeeded: (integer >> i) & Image.Integer(0b11))
                    let twoPixelColor = rgbColor2Table[twoPixelValue]
                    buffer[offset] = twoPixelColor
                    offset += 1
                    i -= 2
                }
            }
            
            /* Go to the next row */
            offset += offsetIncrement
            integerIndex += integerIndexIncrement
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
                let integer = image.data[integerIndex]
                integerIndex += 1
                
                /* Do no not copy pixels after the end of the image */
                let bitCount = min(Image.Integer.bitWidth, image.width - integerIndexInRow * Image.Integer.bitWidth)
                
                /* Copy the pixels */
                for i in 0..<bitCount {
                    let pixelValue = (integer >> (Image.Integer.bitWidth - 1 - i)) & Image.Integer(1)
                    if pixelValue == Image.Integer(1) {
                        buffer[offset] = RgbBlack
                    }
                    offset += 1
                }
            }
        }
    }
    
    public static func createRgbData(width: Int, height: Int) -> UnsafeMutableRawPointer {
        
        let length = width * height * MemoryLayout<RgbColor>.size
        return UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 0)
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
    
    public static func createImage(forRgbData data: UnsafeMutableRawPointer, isOwner: Bool, width: Int, height: Int) -> CGImage {
        
        let length = width * height * MemoryLayout<RgbColor>.size
        let dataProvider = CGDataProvider(dataInfo: isOwner ? data : nil, data: data, size: length, releaseData: {
            (dataInfo: UnsafeMutableRawPointer?, data: UnsafeRawPointer, length: Int) in
            if dataInfo != nil {
                data.deallocate()
            }
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

