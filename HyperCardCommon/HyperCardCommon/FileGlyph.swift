//
//  FileGlyph.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// Glyph with lazy loading from a file
public extension Glyph {
    
    public convenience init(maximumAscent: Int, maximumKerning: Int, fontRectangleHeight: Int, width: Int, offset: Int, startImageOffset: Int, endImageOffset: Int, bitImage: Image) {
        
        self.init()
        
        self.width = width
        self.imageOffset = maximumKerning + offset
        self.imageTop = maximumAscent
        self.imageWidth = endImageOffset - startImageOffset
        self.imageHeight = fontRectangleHeight
        self.isThereImage = (endImageOffset > startImageOffset)
        self.imageProperty.lazyCompute { () -> MaskedImage? in
            return Glyph.loadImage(startOffset: startImageOffset, endOffset: endImageOffset, bitImage: bitImage)
        }
    }
    
    private static func loadImage(startOffset: Int, endOffset: Int, bitImage: Image) -> MaskedImage? {
        
        /* If the image has a null width, there is no image */
        guard endOffset > startOffset else {
            return nil
        }
        
        /* Load the image */
        let drawing = Drawing(width: endOffset - startOffset, height: bitImage.height)
        drawing.drawImage(bitImage, position: Point(x: 0, y: 0), rectangleToDraw: Rectangle(top: 0, left: startOffset, bottom: bitImage.height, right: endOffset))
        
        return MaskedImage(image: drawing.image)
        
    }
    
}
