//
//  FileGlyph.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// Subclass of Glyph with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileGlyph: Glyph {
    
    private let bitImage: Image
    private let bitmapLocationTable: [Int]
    private let index: Int
    
    public init(maximumAscent: Int, maximumKerning: Int, fontRectangleHeight: Int, widthTable: [Int], offsetTable: [Int], bitmapLocationTable: [Int], bitImage: Image, index: Int) {
        self.bitImage = bitImage
        self.bitmapLocationTable = bitmapLocationTable
        self.index = index
        
        super.init()
        
        self.width = widthTable[index]
        self.imageOffset = maximumKerning + offsetTable[index]
        self.imageTop = maximumAscent
        let (startOffset, endOffset) = retrieveImageOffsets()
        self.imageWidth = endOffset - startOffset
        self.imageHeight = fontRectangleHeight
        self.isThereImage = (endOffset > startOffset)
    }
    
    private var imageLoaded = false
    override public var image: MaskedImage? {
        get {
            if !imageLoaded {
                super.image = loadImage()
                imageLoaded = true
            }
            return super.image
        }
        set {
            imageLoaded = true
            super.image = newValue
        }
    }
    
    private func loadImage() -> MaskedImage? {
        
        /* Get the position of the image in the resource bitmap */
        let (startOffset, endOffset) = retrieveImageOffsets()
        
        /* If the image has a null width, there is no image */
        guard endOffset > startOffset else {
            return nil
        }
        
        /* Load the image */
        let drawing = Drawing(width: endOffset - startOffset, height: bitImage.height)
        drawing.drawImage(bitImage, position: Point(x: 0, y: 0), rectangleToDraw: Rectangle(top: 0, left: startOffset, bottom: bitImage.height, right: endOffset))
        
        return MaskedImage(image: drawing.image)
        
    }
    
    private func retrieveImageOffsets() -> (Int, Int) {
        
        let startOffset = bitmapLocationTable[index]
        let endOffset = bitmapLocationTable[index+1]
        
        return (startOffset, endOffset)
    }
    
}
