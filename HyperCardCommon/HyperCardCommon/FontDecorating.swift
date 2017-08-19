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
    public static func decorateFont(from baseFont: BitmapFont, with style: TextStyle, in family: FontFamily) -> BitmapFont {
        
        /* Copy the font */
        let font = BitmapFont()
        font.maximumWidth = baseFont.maximumWidth
        font.maximumKerning = baseFont.maximumKerning
        font.fontRectangleWidth = baseFont.fontRectangleWidth
        font.fontRectangleHeight = baseFont.fontRectangleHeight
        font.maximumAscent = baseFont.maximumAscent
        font.maximumDescent = baseFont.maximumDescent
        
        /* Decorate the glyphs */
        font.glyphs = baseFont.glyphs.map({ DecoratedGlyph(baseGlyph: $0, style: style) })
        
        /* Adjust the metrics */
        FontDecorating.adjustMeasures(of: font, for: style)
        
        return font
    }
    
    private static func adjustMeasures(of font: BitmapFont, for style: TextStyle) {
        
        if style.bold {
            font.maximumWidth += 1
            font.fontRectangleWidth += 1
        }
        
        if style.italic {
            font.maximumKerning -= font.maximumDescent/2
            font.fontRectangleWidth += font.fontRectangleHeight/2
        }
        
        if style.underline {
            font.fontRectangleWidth += 2
            if font.maximumDescent < 2 {
                font.fontRectangleHeight += 2 - font.maximumDescent
                font.maximumDescent = 2
            }
        }
        
        if style.outline {
            font.maximumWidth += 1
            font.maximumKerning -= 1
            font.fontRectangleWidth += 2
            font.fontRectangleHeight += 2
            font.maximumAscent += 1
            font.maximumDescent += 1
        }
        
        if style.shadow {
            let value = (style.outline ? 2 : 1)
            font.maximumWidth += value
            font.fontRectangleWidth += value
            font.maximumDescent += value
            font.fontRectangleHeight += value
        }
        
        if style.condense {
            font.maximumWidth -= 1
        }
        
        if style.extend {
            font.maximumWidth += 1
        }
        
    }
    
}



/// A glyph that lazily applies a font variation to a base glyph
public class DecoratedGlyph: Glyph {
    
    private let baseGlyph: Glyph
    private let style: TextStyle
    
    public init(baseGlyph: Glyph, style: TextStyle) {
        self.baseGlyph = baseGlyph
        self.style = style
        
        super.init()
        
        /* Copy the measures of the base glyph */
        self.width = baseGlyph.width
        self.imageOffset = baseGlyph.imageOffset
        self.imageTop = baseGlyph.imageTop
        
        /* Change the measures for the style */
        self.readjustMeasures()
    }
    
    private func readjustMeasures() {
        
        /* Bold (inferred by Outline and Shadow): add black pixel next to every black pixel */
        if style.bold {
            self.width += 1
        }
        
        /* Italic: slant with slope 2, and the glyph origin must be the same */
        if style.italic {
            if let image = baseGlyph.image {
                self.imageOffset -= (image.height - baseGlyph.imageTop) / 2
            }
        }
        
        /* Outline: every black pixel becomes white and surrounded by four black pixels */
        if style.outline || style.shadow {
            self.imageOffset -= 1
            self.imageTop += 1
            self.width += 1
        }
        
        if style.shadow {
            self.width += style.shadow ? 2 : 1
        }
        
        if style.condense {
            self.width -= 1
        }
        
        if style.extend {
            self.width += 1
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
        guard let baseMaskedImage = baseGlyph.image else {
            return nil
        }
        
        /* We don't accept masks */
        guard case MaskedImage.Layer.bitmap(image: let baseImage, imageRectangle: _, realRectangleInImage: _) = baseMaskedImage.image else {
            return nil
        }
        
        /* Build the image */
        let drawing = buildPlainImage(fromBase: baseImage)
        
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
                drawing.shiftRowRight((self.imageTop - y) / 2)
                
                /* Draw it on the image */
                drawing.applyRow(Point(x: 0, y: y), length: drawing.width, composition: {(a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in a = b})
                
            }
            
        }
        
        /* Underline: draw a line under every character */
        if style.underline {
            
            var lastDrawnX = -1
            let y = self.imageTop + 1
            
            for x in 0..<drawing.width {
                
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
            
            /* Shadow */
            if style.shadow {
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 0))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 0))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 1))
                drawing.drawImage(initialBitmap, position: Point(x: 2, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: 1, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: 0, y: 2))
                drawing.drawImage(initialBitmap, position: Point(x: 0, y: 2))
                
                /* If outline and shadow are both set, a second shadow is draw */
                if style.outline {
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 0))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 0))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 1))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 2))
                    drawing.drawImage(initialBitmap, position: Point(x: 3, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 2, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 1, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 0, y: 3))
                    drawing.drawImage(initialBitmap, position: Point(x: 0, y: 3))
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
    
    private func buildPlainImage(fromBase image: Image) -> Drawing {
        
        var size = Size(width: image.width, height: image.height)
        var baseX = 0
        var baseY = 0
        
        /* Bold (inferred by Outline and Shadow): add black pixel next to every black pixel */
        if style.bold {
            size.width += 1
        }
        
        /* Italic: slant with slope 2, and the glyph origin must be the same */
        if style.italic {
            size.width += size.height / 2
            baseX += (size.height - imageTop) / 2
        }
        
        /* Underline: check that there is enough room for the line */
        if style.underline {
            let descent = image.height - baseGlyph.imageTop
            if descent < 2 {
                size.height += 2 - descent
            }
            size.width += 2
        }
        
        /* Outline: every black pixel becomes white and surrounded by four black pixels */
        if style.outline || style.shadow {
            size.width += 2
            size.height += 2
            baseX += 1
            baseY += 1
        }
        
        if style.shadow {
            let increment = style.outline ? 2 : 1
            size.width += increment
            size.height += increment
        }
        
        /* Build the drawing */
        let drawing = Drawing(width: size.width, height: size.height)
        drawing.drawImage(image, position: Point(x: baseX, y: baseY))
        return drawing
    }
    
}
