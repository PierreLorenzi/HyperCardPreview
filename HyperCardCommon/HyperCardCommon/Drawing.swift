//
//  Drawing.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 19/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public typealias ImageComposition = (inout UInt32, UInt32, Int, Int) -> ()



public class Drawing {
    
    public var image: Image
    
    private var row: [UInt32]
    
    public var width: Int {
        return image.width
    }
    public var height: Int {
        return image.height
    }
    
    public static let DirectComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a |= b }
    public static let MaskComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a &= ~b }
    public static let XorComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a ^= b}
    public static let NoComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in return }
    
    public init(width: Int, height: Int) {
        self.image = Image(width: width, height: height)
        self.row = [UInt32](repeating: 0, count: image.integerCountInRow + 1)
    }
    
    /* Pixel-wide editing */
    public subscript(x: Int, y: Int) -> Bool {
        get {
            return image[x, y]
        }
        set {
            image[x, y] = newValue
        }
    }
    
    public func clear() {
        for i in 0..<image.data.count {
            image.data[i] = UInt32.allZeros
        }
    }
    
    public func drawRectangle(_ unclippedRectangle: Rectangle, clipRectangle optionalClipRectangle: Rectangle? = nil, composition: ImageComposition = DirectComposition) {
        
        /* Clip */
        let clipRectangle = makeValidClipRectangle(optionalClipRectangle)
        let rectangle = computeRectangleIntersection(unclippedRectangle, clipRectangle)
        guard rectangle.width > 0 && rectangle.height > 0 else {
            return
        }
        
        /* Fill it with the mask of the rectangle */
        self.fillRowWithMask(rectangle.left & 31, length: rectangle.width)
        
        /* Loop on the rows */
        for y in rectangle.top..<rectangle.bottom {
            
            /* Draw the row */
            self.applyRow(Point(x: rectangle.left, y: y), length: rectangle.width, composition: composition)
        }
        
    }
    
    private func makeValidClipRectangle(_ userClipRectangle: Rectangle?) -> Rectangle {
        
        let wholeRectangle = Rectangle(top: 0, left: 0, bottom: height, right: width)
        
        if let rectangle = userClipRectangle {
            return computeRectangleIntersection(rectangle, wholeRectangle)
        }
        
        return wholeRectangle
    }
    
    public func drawImage(_ image: Image, position unclippedPosition: Point, rectangleToDraw: Rectangle? = nil, clipRectangle optionalClippingRectangle: Rectangle? = nil, composition: ImageComposition = DirectComposition) {
        
        /* Correct optional argument */
        let unclippedRectangle = rectangleToDraw ?? Rectangle(top: 0, left: 0, bottom: image.height, right: image.width)
        
        /* Clip */
        let clippingRectangle = makeValidClipRectangle(optionalClippingRectangle)
        let (position, rectangle) = clipImageDrawing(unclippedPosition, rectangleToDraw: unclippedRectangle, clipRectangle: clippingRectangle)
        guard rectangle.width > 0 && rectangle.height > 0 else {
            return
        }
        
        /* Store the size */
        let length = rectangle.width
        
        /* Compute the shift mod 32 between source and destination */
        let shift = position.x & 31 - rectangle.left & 31
        
        /* Store the positions of the rows */
        var imagePosition = Point(x: rectangle.left, y: rectangle.top)
        var selfPosition = position
        
        /* Loop on the rows */
        for _ in 0..<rectangle.height {
            
            /* Draw a row of the image into the buffer */
            fillRowWithImage(image, position: imagePosition, length: length)
            
            /* Shift the row to align it with self bitwise */
            shiftRowRight(shift)
            
            /* Draw the row to self */
            applyRow(selfPosition, length: length, composition: composition)
            
            /* Move to next row */
            imagePosition.y += 1
            selfPosition.y += 1
            
        }
    }
    
    private func clipImageDrawing(_ position: Point, rectangleToDraw: Rectangle, clipRectangle: Rectangle) -> (position: Point, rectangleToDraw: Rectangle) {
        
        /* Clip the rectangle: write the clip rectangle in the source image coordinates */
        let sourceClipRectangle = Rectangle(
            x: clipRectangle.x - position.x + rectangleToDraw.x,
            y: clipRectangle.y - position.y + rectangleToDraw.y,
            width: clipRectangle.width,
            height: clipRectangle.height)
        let clippedRectangleToDraw = computeRectangleIntersection(rectangleToDraw, sourceClipRectangle)
        
        /* Point: prevent negative coordinates */
        let clippedPositionX = position.x + clippedRectangleToDraw.x - rectangleToDraw.x
        let clippedPositionY = position.y + clippedRectangleToDraw.y - rectangleToDraw.y
        let clippedPosition = Point(x: clippedPositionX, y: clippedPositionY)
        
        return (clippedPosition, clippedRectangleToDraw)
    }
    
    public func fillRowWithImage(_ image: Image, position: Point, length: Int) {
        
        /* Check which integers are involved */
        let integerIndex = position.y * image.integerCountInRow + position.x / 32
        let integerLength = (upToMultiple(position.x + length, 32) - downToMultiple(position.x, 32)) / 32
        
        /* Fill the buffer with a position mask */
        fillRowWithMask(position.x & 31, length: length)
        
        /* Copy the image to the buffer */
        for i in 0..<integerLength {
            self.row[i] &= image.data[i + integerIndex]
        }
        for i in integerLength..<self.row.count {
            self.row[i] = 0
        }
        
    }
    
    public func fillRowWithMask(_ index: Int, length: Int) {
        
        let allOnes = ~UInt32.allZeros
        
        /* Check which integers are involved */
        let integerStartIndex = index / 32
        let integerEndIndex = (index + length-1) / 32
        
        /* Get the border masks */
        let startBitIndex = UInt32(index & 31)
        let startMask = allOnes >> startBitIndex
        let endBitIndex = UInt32((index + length-1) & 31)
        let endMask = allOnes << (31 - endBitIndex)
        
        /* Fill the row */
        for i in 0..<integerStartIndex {
            self.row[i] = 0
        }
        for i in integerStartIndex...integerEndIndex {
            self.row[i] = allOnes
        }
        for i in (integerEndIndex+1)..<row.count {
            self.row[i] = 0
        }
        
        /* Cut the borders */
        self.row[integerStartIndex] &= startMask
        self.row[integerEndIndex] &= endMask
        
    }
    
    public func applyRow(_ position: Point, length: Int, composition: ImageComposition = DirectComposition) {
        
        /* Check which integers are involved */
        let integerIndex = position.y * self.image.integerCountInRow + position.x / 32
        let integerLength = (upToMultiple(position.x + length, 32) - downToMultiple(position.x, 32)) / 32
        
        let rowIntegerIndex = position.x / 32
        
        /* Apply the integers in-between */
        for i in 0..<integerLength {
            composition(&self.image.data[i + integerIndex], row[i], rowIntegerIndex + i, position.y)
        }
        
    }
    
    public func shiftRowRight(_ value: Int) {
        assert(value >= -32 && value <= 32)
        
        /* Quick case */
        if value == 0 {
            return
        }
        
        /* If the shift is to the right */
        if value > 0 {
            let value32 = UInt32(value)
            for i in (1..<self.row.count).reversed() {
                self.row[i] >>= value32
                self.row[i] |= (row[i-1] << (32 - value32))
            }
            self.row[0] >>= value32
        }
        
        /* If the shift is to the left */
        if value < 0 {
            let value32 = UInt32(-value)
            for i in 0..<(row.count-1) {
                self.row[i] <<= value32
                self.row[i] |= (row[i+1] >> (32 - value32))
            }
            self.row[row.count-1] <<= value32
        }
        
    }
    
    public func drawMaskedImage(_ image: MaskedImage, position: Point, rectangleToDraw: Rectangle? = nil, clipRectangle: Rectangle? = nil, imageComposition: ImageComposition? = Drawing.DirectComposition, maskComposition: ImageComposition? = Drawing.MaskComposition) {
        
        /* Correct optional argument */
        let rectangle = rectangleToDraw ?? Rectangle(top: 0, left: 0, bottom: image.height, right: image.width)
        
        if let composition = maskComposition {
            drawMaskedImageLayer(image.mask, position: position, rectangleToDraw: rectangle, clipRectangle: clipRectangle, composition: composition)
        }
        if let composition = imageComposition {
            drawMaskedImageLayer(image.image, position: position, rectangleToDraw: rectangle, clipRectangle: clipRectangle, composition: composition)
        }
        
    }
    
    private func drawMaskedImageLayer(_ layer: MaskedImage.Layer, position: Point, rectangleToDraw: Rectangle, clipRectangle: Rectangle?, composition: ImageComposition) {
        
        switch layer {
            
        case .bitmap(image: let layer, imageRectangle: let layerRectangle, realRectangleInImage: let realRectangleInLayer):
            
            /* Compute the rectangle to draw in the bitmap coordinates */
            let bitmapRectangleToDraw = Rectangle(
                x: rectangleToDraw.x - layerRectangle.x,
                y: rectangleToDraw.y - layerRectangle.y,
                width: rectangleToDraw.width,
                height: rectangleToDraw.height)
            
            /* Compute the portion of the real rectangle to draw */
            let realBitmapRectangleToDraw = computeRectangleIntersection(bitmapRectangleToDraw, realRectangleInLayer)
            
            /* Correct the position for the layer */
            let layerPosition = Point(
                x: position.x + ((rectangleToDraw.x >= layerRectangle.x + realRectangleInLayer.x) ? 0 : layerRectangle.x + realRectangleInLayer.x - rectangleToDraw.x),
                y: position.y + ((rectangleToDraw.y >= layerRectangle.y + realRectangleInLayer.y) ? 0 : layerRectangle.y + realRectangleInLayer.y - rectangleToDraw.y))
            
            /* Draw the layer */
            self.drawImage(layer, position: layerPosition, rectangleToDraw: realBitmapRectangleToDraw, clipRectangle: clipRectangle, composition: composition)
            
        case .rectangular(rectangle: let layerRectangle):
            
            /* Clip it with the rectangle of the layer */
            let layerRectangleToDraw = computeRectangleIntersection(rectangleToDraw, layerRectangle)
            
            /* Correct the position for the layer */
            let layerPosition = Point(
                x: position.x + ((rectangleToDraw.x >= layerRectangle.x) ? 0 : layerRectangle.x - rectangleToDraw.x),
                y: position.y + ((rectangleToDraw.y >= layerRectangle.y) ? 0 : layerRectangle.y - rectangleToDraw.y))
            
            /* Clip the rectangle */
            let unclippedMaskRectangle = Rectangle(x: layerPosition.x, y: layerPosition.y, width: layerRectangleToDraw.width, height: layerRectangleToDraw.height)
            let maskRectangle = computeRectangleIntersection(unclippedMaskRectangle, clipRectangle ?? Rectangle(x: 0, y: 0, width: self.width, height: self.height))
            
            self.drawRectangle(maskRectangle, composition: composition)
            
        case .clear:
            break
            
        }
        
    }
    
    public func drawString(_ string: HString, index: Int = 0, length optionalLength: Int? = nil, position: Point, font: BitmapFont, clip: Rectangle? = nil, composition: @escaping ImageComposition = Drawing.DirectComposition, maskComposition: @escaping ImageComposition = Drawing.MaskComposition) {
        
        /* Correct the optional arguments */
        let length = optionalLength ?? (string.length - index)
        
        var offset = position.x
        let baseLineY = position.y
        
        for i in index..<(index + length) {
            
            if let clip = clip, offset >= clip.right {
                break
            }
            
            /* Check the character is in the font. If it is not present, draw the missing glyph */
            let character = string[i]
            let glyph = font.glyphs[Int(character)]
            
            /* Draw the glyph if it has an image */
            if let image = glyph.image {
                let characterX = offset + glyph.imageOffset
                let characterY = baseLineY - glyph.imageTop
                self.drawMaskedImage(image, position: Point(x: characterX, y: characterY), clipRectangle: clip, imageComposition: composition, maskComposition: maskComposition)
            }
            
            /* Go forth */
            offset += glyph.width
            
        }
        
    }
    
    public func drawPattern(_ image: Image, rectangle: Rectangle, offset: Point = Point(x: 0, y: 0), composition: ImageComposition = DirectComposition) {
        
        /* Compute an origin closest to the top left of the rectangle */
        let rectangleXModulo = (rectangle.left - offset.x) % image.width
        let rectangleYModulo = (rectangle.top - offset.y) % image.height
        let closestOrigin = Point(x: rectangle.left - rectangleXModulo, y: rectangle.top - rectangleYModulo)
        
        /* Draw the images */
        var originX = closestOrigin.x
        while originX < rectangle.right {
            
            var originY = closestOrigin.y
            while originY < rectangle.bottom {
                
                self.drawImage(image, position: Point(x: originX, y: originY), rectangleToDraw: nil, clipRectangle: rectangle, composition: composition)
                originY += image.height
            }
            
            originX += image.width
        }
        
    }
    
}
