//
//  FileGlyph.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// Glyph with lazy loading from a file
public extension Glyph {
    
    public convenience init(maximumAscent: Int, maximumKerning: Int, fontRectangleHeight: Int, widthTable: [Int], offsetTable: [Int], bitmapLocationTable: [Int], bitImage: Image, index: Int) {
        
        self.init()
        
        /* Get the offsets in the bit image */
        let startOffset = bitmapLocationTable[index]
        let endOffset = bitmapLocationTable[index + 1]
        
        self.width = widthTable[index]
        self.imageOffset = maximumKerning + offsetTable[index]
        self.imageTop = maximumAscent
        self.imageWidth = endOffset - startOffset
        self.imageHeight = fontRectangleHeight
        self.isThereImage = (endOffset > startOffset)
        self.imageProperty.lazyCompute { () -> MaskedImage? in
            return Glyph.loadImage(startOffset: startOffset, endOffset: endOffset, bitImage: bitImage)
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
