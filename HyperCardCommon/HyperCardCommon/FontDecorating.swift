//
//  FontDecorator.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 18/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//



/* Differences from original: underline extends too much around the characters, start offset of text can shift one pixel */


public enum FontDecorating {
    
    /// Applies a font variation to a bitmap font
    public static func decorateFont(from baseFont: BitmapFont, with style: TextStyle, in family: FontFamily, size: Int) -> BitmapFont {
        
        /* Copy the font */
        let font = BitmapFont()
        font.maximumWidth = baseFont.maximumWidth
        font.maximumKerning = baseFont.maximumKerning
        font.fontRectangleWidth = baseFont.fontRectangleWidth
        font.fontRectangleHeight = baseFont.fontRectangleHeight
        font.maximumAscent = baseFont.maximumAscent
        font.maximumDescent = baseFont.maximumDescent
        font.leading = baseFont.leading
        
        /* Decorate the glyphs */
        font.glyphs = baseFont.glyphs.map({ DecoratedGlyph(baseGlyph: $0, style: style, properties: family.styleProperties, size: size, maximumDescent: font.maximumDescent) })
        
        /* Adjust the metrics */
        FontDecorating.adjustMeasures(of: font, for: style, properties: family.styleProperties, size: size)
        
        return font
    }
    
    private static func adjustMeasures(of font: BitmapFont, for style: TextStyle, properties: FontStyleProperties?, size: Int) {
        
        if style.bold {
            font.maximumWidth += computeExtraWidth(byDefault: 1, property: properties?.boldExtraWidth, size: size)
            font.fontRectangleWidth += 1
        }
        
        if style.italic {
            font.maximumWidth += computeExtraWidth(byDefault: 0, property: properties?.italicExtraWidth, size: size)
            font.maximumKerning -= font.maximumDescent/2
            font.fontRectangleWidth += font.fontRectangleHeight/2
        }
        
        if style.underline {
            font.maximumWidth += computeExtraWidth(byDefault: 0, property: properties?.underlineExtraWidth, size: size)
            font.fontRectangleWidth += 2
            if font.maximumDescent < 2 {
                font.fontRectangleHeight += 2 - font.maximumDescent
                font.maximumDescent = 2
            }
        }
        
        if style.outline || style.shadow {
            font.maximumWidth += computeExtraWidth(byDefault: 1, property: properties?.outlineExtraWidth, size: size)
            font.maximumKerning -= 1
            font.fontRectangleWidth += 2
            font.fontRectangleHeight += 2
            font.maximumAscent += 1
            font.maximumDescent += 1
        }
        
        if style.shadow {
            let value = (style.outline ? 2 : 1)
            font.maximumWidth += value * computeExtraWidth(byDefault: 1, property: properties?.shadowExtraWidth, size: size)
            font.fontRectangleWidth += value
            font.maximumDescent += value
            font.fontRectangleHeight += value
        }
        
        if style.condense {
            font.maximumWidth += computeExtraWidth(byDefault: -1, property: properties?.condensedExtraWidth, size: size)
        }
        
        if style.extend {
            font.maximumWidth += computeExtraWidth(byDefault: 1, property: properties?.extendedExtraWidth, size: size)
        }
        
    }
    
}


private func computeExtraWidth(byDefault: Int, property: Double?, size: Int) -> Int {
    
    if let property = property {
        let value = property * Double(size)
        
        /* Ths rounding rule was not the same, it caused a glitch in a stack */
        if value - floor(value) == 0.5 {
            return Int(value)
        }
        return Int(round(value))
    }
    
    return byDefault
}


/// A glyph that lazily applies a font variation to a base glyph
public class DecoratedGlyph: Glyph {
    
    private let baseGlyph: Glyph
    private let style: TextStyle
    private let properties: FontStyleProperties?
    private let size: Int
    private let maximumDescent: Int
    
    private var imageWidth: Int
    private var imageHeight: Int
    
    public init(baseGlyph: Glyph, style: TextStyle, properties: FontStyleProperties?, size: Int, maximumDescent: Int) {
        self.baseGlyph = baseGlyph
        self.style = style
        self.properties = properties
        self.size = size
        self.maximumDescent = maximumDescent
        
        self.imageWidth = baseGlyph.image?.width ?? 0
        self.imageHeight = baseGlyph.image?.height ?? 0
        
        super.init()
        
        /* Copy the measures of the base glyph */
        self.width = baseGlyph.width
        self.imageOffset = baseGlyph.imageOffset
        self.imageTop = baseGlyph.imageTop
        
        /* Change the measures for the style */
        self.readjustMeasures()
    }
    
    private func readjustMeasures() {
        
        /* Underline: if there is no image, make an image of the line under */
        if style.underline && baseGlyph.image == nil {
            self.imageOffset = 0
            self.imageTop = -1
            self.imageWidth = baseGlyph.width
            self.imageHeight = 1
        }
        
        /* Bold (inferred by Outline and Shadow): add black pixel next to every black pixel */
        if style.bold {
            self.width += computeExtraWidth(byDefault: 1, property: properties?.boldExtraWidth, size: size)
            self.imageWidth += 1
        }
        
        /* Italic: slant with slope 2, and the glyph origin must be the same */
        if style.italic {
            self.width += computeExtraWidth(byDefault: 0, property: properties?.italicExtraWidth, size: size)
            self.imageWidth += self.imageHeight / 2
            self.imageOffset -= (self.imageHeight - self.imageTop) / 2
        }
        
        /* Underline: check that there is enough room for the line */
        if style.underline {
            
            /* Add pixels under if necessary */
            let descent = self.imageHeight - self.imageTop
            if descent < 2 {
                self.imageHeight += 2 - descent
            }
        }
        
        /* Outline: every black pixel becomes white and surrounded by four black pixels */
        if style.outline || style.shadow {
            self.imageOffset -= 1
            self.imageTop += 1
            self.width += computeExtraWidth(byDefault: 1, property: properties?.outlineExtraWidth, size: size)
            self.imageWidth += 2
            self.imageHeight += 2
        }
        
        if style.shadow {
            let value = style.outline ? 2 : 1
            self.width += value * computeExtraWidth(byDefault: 1, property: properties?.shadowExtraWidth, size: size)
            self.imageWidth += value
            self.imageHeight += value
        }
        
        if style.condense {
            self.width += computeExtraWidth(byDefault: -1, property: properties?.condensedExtraWidth, size: size)
        }
        
        if style.extend {
            self.width += computeExtraWidth(byDefault: 1, property: properties?.extendedExtraWidth, size: size)
        }
        
        /* Underline: add pixels on both sides, the line extends from 0 to width */
        if style.underline {
            if self.imageOffset > 0 {
                self.imageWidth += self.imageOffset
                self.imageOffset = 0
            }
            if self.imageOffset + self.imageWidth < self.width {
                self.imageWidth = self.width - self.imageOffset
            }
        }
        
    }
    
    private var imageLoaded = false
    public override var image: MaskedImage? {
        get {
            if !imageLoaded {
                super.image = buildImage()
                imageLoaded = true
            }
            return super.image
        }
        set {
            super.image = newValue
        }
    }
    
    private func buildImage() -> MaskedImage? {
        
        /* Check if there is an image in the base glyph */
        guard self.imageWidth > 0 && self.imageHeight > 0 else {
            return nil
        }
        
        /* Build the image */
        let drawing = Drawing(width: self.imageWidth, height: self.imageHeight)
        
        /* Draw the glyph on it */
        if let baseMaskedImage = baseGlyph.image {
            if case MaskedImage.Layer.bitmap(image: let baseImage, imageRectangle: _, realRectangleInImage: _) = baseMaskedImage.image {
                
                drawing.drawImage(baseImage, position: Point(x: baseGlyph.imageOffset - self.imageOffset, y: self.imageTop - baseGlyph.imageTop))
            }
        }
        
        var mask: MaskedImage.Layer = .clear
        
        /* Bold: add a black pixel on the right of every black pixel */
        if style.bold {
            
            /* Loop on the rows */
            for y in 0..<drawing.height {
                
                /* Get the row */
                drawing.fillRowWithImage(drawing.image, position: Point(x: 0, y: y), length: drawing.width)
                
                /* Shift it right */
                drawing.shiftRowRight(1)
                
                /* Draw it on the image */
                drawing.applyRow(Point(x: 0, y: y), length: drawing.width)
                
            }
            
        }
        
        /* Italic: slant with slope 2 from baseline */
        if style.italic {
            
            /* Loop on the rows */
            for y in 0..<drawing.height {
                
                /* Get the row */
                drawing.fillRowWithImage(drawing.image, position: Point(x: 0, y: y), length: drawing.width)
                
                /* Shift it right */
                drawing.shiftRowRight( (imageTop - y + maximumDescent - 1) / 2 - maximumDescent / 2)
                
                /* Draw it on the image */
                drawing.applyRow(Point(x: 0, y: y), length: drawing.width, composition: {(a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a = b})
                
            }
            
        }
        
        /* Underline: draw a line under every character */
        if style.underline {
            
            var lastDrawnX = -1
            let y = self.imageTop + 1
            
            for x in (-self.imageOffset)..<(-self.imageOffset + self.width) {
                
                /* The underline must stop if there is a black pixel nearby */
                if drawing[x, y] {
                    continue
                }
                if lastDrawnX != x-1 && x > 0 && drawing[x-1, y] {
                    continue
                }
                if x > 0 && y > 0 && drawing[x-1,y-1] {
                    continue
                }
                if y > 0 && drawing[x,y-1] {
                    continue
                }
                if y > 0 && x < drawing.width-1 && drawing[x+1, y-1] {
                    continue
                }
                if x < drawing.width-1 && drawing[x+1, y] {
                    continue
                }
                if x < drawing.width && y < drawing.height-1 && drawing[x+1, y+1] {
                    continue
                }
                if y < drawing.height-1 && drawing[x, y+1] {
                    continue
                }
                if y < drawing.height-1 && x > 0 && drawing[x-1, y+1] {
                    continue
                }
                
                lastDrawnX = x
                drawing[x, y] = true
            }
            
        }
        
        /* Outline & Shadow */
        if style.shadow || style.outline {
            let initialBitmap = drawing.image
            
            /* Outline */
            drawing.drawImage(initialBitmap, position: Point(x: -1, y: 0))
            drawing.drawImage(initialBitmap, position: Point(x: -1, y: -1))
            drawing.drawImage(initialBitmap, position: Point(x: 0, y: -1))
            drawing.drawImage(initialBitmap, position: Point(x: 1, y: -1))
            drawing.drawImage(initialBitmap, position: Point(x: 1, y: 0))
            drawing.drawImage(initialBitmap, position: Point(x: 1, y: 1))
            drawing.drawImage(initialBitmap, position: Point(x: 0, y: 1))
            drawing.drawImage(initialBitmap, position: Point(x: -1, y: 1))
            
            /* Keep a clean underline */
            var row: [UInt32] = []
            if style.underline {
                
                /* Remove the pixels around the underline that the outline has put */
                if style.underline {
                    let lineY = self.imageTop + 1
                    let leftPixelX = -self.imageOffset - 1
                    let rightPixelX = -self.imageOffset + self.width
                    if leftPixelX >= 0 && !initialBitmap[leftPixelX, lineY] {
                        drawing[leftPixelX, lineY] = false
                    }
                    if rightPixelX < drawing.width && !initialBitmap[rightPixelX, lineY] {
                        drawing[rightPixelX, lineY] = false
                    }
                }
                
                /* Save the state of the underline before applying the shadow */
                let newRow = drawing.image.data[drawing.image.integerCountInRow * (imageTop + 1) ..< drawing.image.integerCountInRow * (imageTop + 2)]
                row = [UInt32](newRow)
            }
            
            /* Shadow */
            if style.shadow {
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: -1))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 0))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 1))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: 1, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: 0, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: -1, y: 2))
                
                /* If outline and shadow are both set, a second shadow is draw */
                if style.outline {
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: -1))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 0))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 1))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 2))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 2, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 1, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 0, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: -1, y: 3))
                }
            }
            
            /* Remove the shadow from the underline */
            if style.underline {
                let firstIntegerIndex = drawing.image.integerCountInRow * (imageTop + 1)
                
                for i in 0..<row.count {
                    drawing.image.data[firstIntegerIndex + i] = row[i]
                }
            }
            
            /* Make the original pixels white */
            drawing.drawImage(initialBitmap, position: Point(x: 0, y: 0), composition: Drawing.MaskComposition)
            let rectangle = Rectangle(top: 0, left: 0, bottom: drawing.height, right: drawing.width)
            mask = MaskedImage.Layer.bitmap(image: initialBitmap, imageRectangle: rectangle, realRectangleInImage: rectangle)
            
        }
        
        let rectangle = Rectangle(top: 0, left: 0, bottom: drawing.height, right: drawing.width)
        let maskedImageImage = MaskedImage.Layer.bitmap(image: drawing.image, imageRectangle: rectangle, realRectangleInImage: rectangle)
        return MaskedImage(width: drawing.width, height: drawing.height, image: maskedImageImage, mask: mask)
    }
    
    private func createUnderlineImage() -> MaskedImage {
        
        var image = Image(width: self.width, height: 1)
        
        /* Make the image black */
        for i in 0..<image.integerCountInRow {
            image.data[i] = UInt32.max
        }
        
        /* Create the masked image */
        let rectangle = Rectangle(top: 0, left: 0, bottom: image.height, right: image.width)
        return MaskedImage(width: image.width, height: image.height, image: .bitmap(image: image, imageRectangle: rectangle, realRectangleInImage: rectangle), mask: .clear)
    }
    
}
