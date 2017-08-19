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
    
    private let font: BitmapFontResourceBlock
    private let index: Int
    
    public init(font: BitmapFontResourceBlock, index: Int) {
        self.font = font
        self.index = index
        
        super.init()
        
        self.width = font.widthTable[index]
        self.imageOffset = font.maximumKerning + font.offsetTable[index]
        self.imageTop = font.maximumAscent
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
        let startOffset = font.bitmapLocationTable[index]
        let endOffset = font.bitmapLocationTable[index+1]
        
        /* If the image has a null width, there is no image */
        guard endOffset > startOffset else {
            return nil
        }
        
        /* Load the image */
        let drawing = Drawing(width: endOffset - startOffset, height: font.bitImage.height)
        drawing.drawImage(font.bitImage, position: Point(x: 0, y: 0), rectangleToDraw: Rectangle(top: 0, left: startOffset, bottom: font.bitImage.height, right: endOffset))
        
        return MaskedImage(image: drawing.image)
        
    }
    
}
