//
//  Drawing.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 19/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// A composition defines how an image is to be super-imposed on another image
/// <p>
/// Here are the arguments:
/// 1: some pixels in a row of the destination image. The process must be applied on them
/// 2: the corresponding pixels in the image that is drawn
/// 3. the index of the 32-bit integer in the row
/// 4. the y-coordinate of the pixels
public typealias ImageComposition = (inout UInt32, UInt32, Int, Int) -> ()



/// This classes handles all the 2D drawing. It contains a 1-bit image (without mask), and
/// methods to draw on it.
public class Drawing {
    
    /// The underlying image
    /// <p>
    /// It is available so optimized processes can be made on the raw data
    public var image: Image
    
    private var row: [UInt32]
    
    /// The width of the drawing, in pixels
    public var width: Int {
        return image.width
    }
    
    /// The height of the drawing, in pixels
    public var height: Int {
        return image.height
    }
    
    /// Direct composition: the black pixels of the drawn image are drawn black
    public static let DirectComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a |= b }
    
    /// Mask Composition: the black pixels of the drawn image are drawn white
    public static let MaskComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a &= ~b }
    
    /// Xor Composition: the target image is inverted at the black pixels of the drawn image
    public static let XorComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a ^= b}
    
    /// No Composition: nothing is drawn
    public static let NoComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in return }
    
    /// Builds a white drawing
    public init(width: Int, height: Int) {
        self.image = Image(width: width, height: height)
        self.row = [UInt32](repeating: 0, count: image.integerCountInRow + 1)
    }
    
    /// Builds a drawing from an image
    public init(image: Image) {
        self.image = image
        self.row = [UInt32](repeating: 0, count: image.integerCountInRow + 1)
    }
    
    /// To edit pixel by pixel
    public subscript(x: Int, y: Int) -> Bool {
        get {
            return image[x, y]
        }
        set {
            image[x, y] = newValue
        }
    }
    
    /// Makes the whole drawing white
    public func clear() {
        for i in 0..<image.data.count {
            image.data[i] = UInt32(0)
        }
    }
    
    /// Draws a rectangle. A clip rectangle can be provided, the rectangle is intersected with it. A composition
    /// can be provided.
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
    
    /// Draws an image. The position is the top-left origin of the point where the image is drawn. rectangleToDraw
    /// is the portion of the image to draw (changing the origin of this rectangle doesn't change the position where
    /// it will be drawn), this rectangle is in the coordinates of the image being drawn, not the drawing. A clip
    /// rectangle can be provided in the cooordinates of the drawing, the resulting image will be intersected with it.
    /// A composition can be provided.
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
    
    /// Fills the internal temporery buffer of the drawing with a row of an image
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
    
    /// Fills the internal temporary buffer of the drawing with a row of a mask
    public func fillRowWithMask(_ index: Int, length: Int) {
        
        let allOnes = ~UInt32(0)
        
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
    
    /// Draws the internal temporary buffer in a row of the drawing
    public func applyRow(_ position: Point, length: Int, composition: ImageComposition = DirectComposition) {
        
        /* Check which integers are involved */
        let integerIndex = position.y * self.image.integerCountInRow + position.x / 32
        let integerLength = (upToMultiple(position.x + length, 32) - downToMultiple(position.x, 32)) / 32
        
        let rowIntegerIndex = position.x / 32
        
        /* Left integer */
        let integerLeft = self.image.data[integerIndex]
        var newIntegerLeft = integerLeft
        composition(&newIntegerLeft, row[0], rowIntegerIndex, position.y)
        let outerPixelCountLeft = position.x % 32
        if outerPixelCountLeft > 0 {
            // I have to use a super weird expression because Swift throws "Shift too large"
            let maskLeft = UInt32.max << UInt32(-outerPixelCountLeft + MemoryLayout<UInt32>.size * 8)
            newIntegerLeft = (newIntegerLeft & ~maskLeft) | (integerLeft & maskLeft)
        }
        
        /* Special case: there is only one integer */
        let outerPixelCountRight = 31 - (position.x + length - 1) % 32
        if integerLength == 1 {
            if outerPixelCountRight > 0 {
                let maskRight = UInt32.max >> UInt32(32 - outerPixelCountRight)
                newIntegerLeft = (newIntegerLeft & ~maskRight) | (integerLeft & maskRight)
            }
            self.image.data[integerIndex] = newIntegerLeft
            return
        }
        
        self.image.data[integerIndex] = newIntegerLeft
        
        /* Right integer */
        let integerRight = self.image.data[integerIndex + integerLength - 1]
        var newIntegerRight = integerRight
        composition(&newIntegerRight, row[integerLength - 1], rowIntegerIndex + integerLength - 1, position.y)
        if outerPixelCountRight > 0 {
            let maskRight = UInt32.max >> UInt32(32 - outerPixelCountRight)
            newIntegerRight = (newIntegerRight & ~maskRight) | (integerRight & maskRight)
        }
        self.image.data[integerIndex + integerLength - 1] = newIntegerRight
        
        /* Apply the integers in-between */
        for i in 1..<(integerLength - 1) {
            composition(&self.image.data[i + integerIndex], row[i], rowIntegerIndex + i, position.y)
        }
        
    }
    
    /// Shifts the internal temporary buffer
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
    
    /// Draws an masked image. The position is the top-left origin of the point where the image is drawn. rectangleToDraw
    /// is the portion of the image to draw (changing the origin of this rectangle doesn't change the position where
    /// it will be drawn), this rectangle is in the coordinates of the image being drawn, not the drawing. A clip
    /// rectangle can be provided in the cooordinates of the drawing, the resulting image will be intersected with it.
    /// Two compositions can be provided, one for the image layer and one for the mask layer.
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
    
    /// Draws a string on the image. A sub-range of the string can be specified. The position is the origin of the
    /// first glyph, it is on the baseline. A font must be provided. A clip rectangle can be provided, the
    /// glyphs will be intersected with it. Two compositions may be provided, for the image layer and for the
    /// mask layer of the glyphs.
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
    
    /// Fills a rectangle with a pattern, that is, a tiled image. offset is the shift to apply to
    /// the pattern, by default the pattern is aligned with the top-left of the image. A composition
    // can be provided.
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
