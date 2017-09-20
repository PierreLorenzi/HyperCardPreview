//
//  MaskedImage.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit



/// A 1-bit image with a 1-bit mask
/// <p>
/// The structure of this object is a little complex because it is meant to handle card
/// bitmaps, which have a special strucure. It is not just an image and a mask side by side.
/// Both the image and the mask can be restricted to a sub-area of the whole image, and
/// they can be declared as filled rectangles instead of pixel data.
/// <p>
/// The mask is not a multiplicative mask, it just gives the position of the white pixels.
/// When a pixel is set in the image layer and not in the mask, it is black.
public struct MaskedImage {
    
    /// The width of the image, in pixels
    public let width: Int
    
    /// The height of the image, in pixels
    public let height: Int
    
    /// The image layer
    public let image: MaskedImage.Layer
    
    /// The mask layer
    public let mask: MaskedImage.Layer
    
    /// A layer can be either a bitmap restricted to a sub-rectangle of the whole image,
    /// a filled sub-rectangle of the image, or nothing.
    public enum Layer {
        case bitmap(image: Image, imageRectangle: Rectangle, realRectangleInImage: Rectangle)
        case rectangular(rectangle: Rectangle)
        case clear
    }
    
    /// The color of a pixel of the image, resulting from the combination of the image layer and
    /// mask layer.
    public enum Color {
        case white
        case black
        case transparent
    }
    
    /// Main constructor
    public init(width: Int, height: Int, image: MaskedImage.Layer, mask: MaskedImage.Layer) {
        self.width = width
        self.height = height
        self.image = image
        self.mask = mask
    }
    
    /// Get the color of the pixel at (x,y)
    /// <p>
    /// x is counted from the left, y from the top
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
    
    /// Builds a masked image from a simple image, making the black pixels black and the while pixels
    /// transparent
    public init(image: Image) {
        let rectangle = Rectangle(top: 0, left: 0, bottom: image.height, right: image.width)
        self.init(width: image.width, height: image.height, image: .bitmap(image: image, imageRectangle: rectangle, realRectangleInImage: rectangle), mask: .clear)
    }
    
    /// Builds the image from an image in the resources
    public init?(named name: String) {
        
        /* Load the image with the proper bundle */
        guard let path = HyperCardBundle.pathForImageResource(NSImage.Name(rawValue: name)),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let representation = NSBitmapImageRep(data: data) else {
                self.init(width: 0, height: 0, image: .clear, mask: .clear)
                return nil
        }
        
        self.init(representation: representation)
    }
    
    /// Builds an image from a Cocoa image
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
    
    /// Build an image from a image in the resources
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
