//
//  FileGlyph.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Glyph {
    
    public convenience init(font: BitmapFontResourceBlock, index: Int) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.width = font.widthTable[index]
        self.imageOffset = font.maximumKerning + font.offsetTable[index]
        self.imageTop = font.maximumAscent
        
        /* Enable lazy initialization */
        
        /* image */
        self.imageProperty.observers.append(LazyInitializer(property: self.imageProperty, initialization: {
            return self.loadImage(font: font, index: index)
        }))
        
    }
    
    private func loadImage(font: BitmapFontResourceBlock, index: Int) -> MaskedImage? {
        
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

