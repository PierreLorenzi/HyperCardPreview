//
//  MaskedImage.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit



public struct MaskedImage {
    
    public let width: Int
    public let height: Int
    
    public let image: MaskedImage.Layer
    public let mask: MaskedImage.Layer
    
    public enum Layer {
        case bitmap(image: Image, imageRectangle: Rectangle, realRectangleInImage: Rectangle)
        case rectangular(rectangle: Rectangle)
        case clear
    }
    
    public enum Color {
        case white
        case black
        case transparent
    }
    
    public init(width: Int, height: Int, image: MaskedImage.Layer, mask: MaskedImage.Layer) {
        self.width = width
        self.height = height
        self.image = image
        self.mask = mask
    }
    
    public subscript(x: Int, y: Int) -> Color {
        
        let position = Point(x: x, y: y)
        
        /* Check image */
        if doesPositionBelongToLayer(position, layer: image) {
            return .black
        }
        
        /* Mask */
        if doesPositionBelongToLayer(position, layer: mask) {
            return .white
        }
        
        /* Everywhere else, it is transparent */
        return .transparent
        
    }
    
    private func doesPositionBelongToLayer(_ position: Point, layer: MaskedImage.Layer) -> Bool {
        
        switch layer {
            
        case .bitmap(image: let image, imageRectangle: let imageRectangle, realRectangleInImage: let realRectangleInImage):
            
            /* Check if the position is a black pixel of the image */
            let positionInImage = Point(x: position.x - imageRectangle.left, y: position.y - imageRectangle.top)
            
            /* The position must be in the real content */
            guard realRectangleInImage.containsPosition(positionInImage) else {
                return false
            }
            
            return image[positionInImage.x, positionInImage.y]
            
        case .rectangular(rectangle: let rectangle):
            return rectangle.containsPosition(position)
            
        case .clear:
            return false
            
        }
        
    }
    
}

public extension MaskedImage {
    
    fileprivate static func convertToRgb(_ color: MaskedImage.Color) -> RgbColor {
        switch color {
        case .white:
            return RgbWhite
        case .black:
            return RgbBlack
        case .transparent:
            return RgbTransparent
        }
    }
    
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


public extension MaskedImage {
    
    public init(image: Image) {
        let rectangle = Rectangle(top: 0, left: 0, bottom: image.height, right: image.width)
        self.init(width: image.width, height: image.height, image: .bitmap(image: image, imageRectangle: rectangle, realRectangleInImage: rectangle), mask: .clear)
    }
    
    public init?(named name: String) {
        
        /* Load the image with the proper bundle */
        guard let path = HyperCardBundle.pathForImageResource(name),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let representation = NSBitmapImageRep(data: data) else {
                self.init(width: 0, height: 0, image: .clear, mask: .clear)
                return nil
        }
        
        self.init(representation: representation)
    }
    
    public init?(representation: NSBitmapImageRep) {
        
        let width = representation.pixelsWide
        let height = representation.pixelsHigh
        
        /* Build the image plans */
        var image = Image(width: width, height: height)
        var mask = Image(width: width, height: height)
        
        /* Fill the image */
        for x in 0..<width {
            for y in 0..<height {
                
                /* Get the color */
                let rawColor = representation.colorAt(x: x, y: y)!
                let color = rawColor.usingColorSpace(NSColorSpace.sRGB)!
                
                /* Black */
                if color.redComponent < 0.1 && color.greenComponent < 0.1 && color.blueComponent < 0.1 && color.alphaComponent > 0.9 {
                    image[x, y] = true
                }
                    
                    /* White */
                else if color.redComponent > 0.9 && color.greenComponent > 0.9 && color.blueComponent > 0.9 && color.alphaComponent > 0.9 {
                    mask[x, y] = true
                }
                
            }
        }
        
        /* Build the image */
        let rectangle = Rectangle(top: 0, left: 0, bottom: height, right: width)
        self.init(width: width, height: height, image: .bitmap(image: image, imageRectangle: rectangle, realRectangleInImage: rectangle), mask: .bitmap(image: mask, imageRectangle: rectangle, realRectangleInImage: rectangle))
    }
    
}

public extension Image {
    
    public init?(named name: String) {
        guard let maskedImage = MaskedImage(named: name) else {
            return nil
        }
        guard case MaskedImage.Layer.bitmap(image: let image, imageRectangle: _, realRectangleInImage: _) = maskedImage.image else {
            return nil
        }
        self = image
    }
    
}
